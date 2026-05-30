//
//  PajemploiDeclaration.swift
//  Manounou
//
//  Modèle de la déclaration mensuelle Pajemploi — d'après le design handoff
//  « Focus Pajemploi » (briques 1 « déclaration assistée » + 2 « avance immédiate »).
//
//  Modèle pur (aucune dépendance Supabase) : il porte les 4 valeurs que le parent
//  recopie sur pajemploi.urssaf.fr (heures, salaire net, indemnités, net à payer)
//  et l'estimation du crédit d'impôt (avance immédiate URSSAF, 50 %).
//
//  Le détail salaire net / indemnités provient d'une grille de taux qui n'est pas
//  encore portée par le backend. Tant que le planning ne fournit pas ces taux,
//  l'écran s'appuie sur `sample` (l'app tourne aujourd'hui en données de démo via
//  `DataService.loadSampleData()`). `from(month:bookings:)` couvre le calcul réel
//  des heures / jours / montant dès que de vraies réservations sont disponibles.
//

import Foundation

struct PajemploiDeclaration: Identifiable, Hashable {
    let id: UUID
    /// Mois déclaré (n'importe quelle date du mois concerné).
    var month: Date
    /// Prénom de la nounou (« net à payer à Fatou »).
    var nounouFirstName: String
    /// Heures d'accueil cumulées sur le mois.
    var hours: Double
    /// Nombre de jours d'accueil (base des indemnités d'entretien).
    var days: Int
    /// Salaire net déclaré (heures × taux net).
    var netSalary: Double
    /// Indemnités d'entretien (jours × indemnité journalière).
    var upkeepAllowance: Double
    /// Net à payer à la nounou — montant phare repris par l'avance immédiate.
    var netToPay: Double

    init(
        id: UUID = UUID(),
        month: Date,
        nounouFirstName: String,
        hours: Double,
        days: Int,
        netSalary: Double,
        upkeepAllowance: Double,
        netToPay: Double
    ) {
        self.id = id
        self.month = month
        self.nounouFirstName = nounouFirstName
        self.hours = hours
        self.days = days
        self.netSalary = netSalary
        self.upkeepAllowance = upkeepAllowance
        self.netToPay = netToPay
    }

    // MARK: - Crédit d'impôt (avance immédiate)

    /// Crédit d'impôt estimé : 50 % du net à payer (avance immédiate URSSAF).
    var taxCredit: Double { netToPay / 2 }

    /// Reste à charge réel après l'avance immédiate.
    var remainingCost: Double { netToPay - taxCredit }

    // MARK: - Formatage affiché (fr_FR)

    /// Titre de mois pour la barre de navigation : « mai ».
    var monthTitle: String {
        Self.monthFormatter.string(from: month)
    }

    /// Heures lisibles : « 86 h ».
    var formattedHours: String {
        "\(Self.hoursString(hours)) h"
    }

    /// Jours lisibles : « 20 ».
    var formattedDays: String { "\(days)" }

    var formattedNetSalary: String { Self.euros(netSalary) }
    var formattedUpkeep: String { Self.euros(upkeepAllowance) }
    var formattedNetToPay: String { Self.euros(netToPay) }
    var formattedTaxCredit: String { "– " + Self.euros(taxCredit) }
    var formattedRemainingCost: String { Self.euros(remainingCost) }

    // MARK: - Valeurs à copier (sans symbole, façon formulaire Pajemploi)

    var copyHours: String { Self.hoursString(hours) }
    var copyNetSalary: String { Self.decimalString(netSalary) }
    var copyUpkeep: String { Self.decimalString(upkeepAllowance) }
    var copyNetToPay: String { Self.decimalString(netToPay) }

    // MARK: - Formatters

    private static let frLocale = Locale(identifier: "fr_FR")

    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = frLocale
        f.dateFormat = "LLLL"
        return f
    }()

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        f.locale = frLocale
        return f
    }()

    private static let decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = frLocale
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    private static func euros(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "\(value) €"
    }

    private static func decimalString(_ value: Double) -> String {
        decimalFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// « 86 » (entier si rond, sinon une décimale : « 86,5 »).
    private static func hoursString(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        }
        let f = NumberFormatter()
        f.locale = frLocale
        f.numberStyle = .decimal
        f.maximumFractionDigits = 1
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

// MARK: - Construction

extension PajemploiDeclaration {

    /// Exemple fidèle au design handoff (« Focus Pajemploi »).
    /// Sert d'aperçu et d'état par défaut tant que l'app tourne en données de démo.
    static var sample: PajemploiDeclaration {
        PajemploiDeclaration(
            month: Date(),
            nounouFirstName: "Fatou",
            hours: 86,
            days: 20,
            netSalary: 387,
            upkeepAllowance: 70,
            netToPay: 472
        )
    }
}
