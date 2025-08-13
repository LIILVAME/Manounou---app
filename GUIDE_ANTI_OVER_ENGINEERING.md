# 🎯 Guide Anti-Over-Engineering - Manounou App

> **Principe fondamental** : Une application réussie est une application que les utilisateurs utilisent réellement, pas une application qui impressionne les développeurs.

## 🚨 **Red Flags à Éviter Absolument**

### **🎨 Design**
| ❌ **À Éviter** | ✅ **À Faire** |
|---|---|
| Dégradés violets partout | Palette cohérente (3-4 couleurs max) |
| Emojis ✨ dans chaque titre | Emojis avec parcimonie, texte clair |
| Icônes massives qui écrasent | Icônes proportionnées au contenu |
| Inter par défaut sans réflexion | Typographie réfléchie et lisible |

### **🔗 Interactions**
| ❌ **À Éviter** | ✅ **À Faire** |
|---|---|
| Boutons sociaux qui ne mènent nulle part | Liens fonctionnels ou supprimés |
| Témoignages factices ("Marie D.") | Témoignages authentiques ou aucun |
| Animations bugguées qui saccadent | Animations fluides <300ms |
| Boutons muets sans feedback | États de chargement partout |

### **⚡ Performance**
| ❌ **À Éviter** | ✅ **À Faire** |
|---|---|
| Actions serveur lentes (dial-up) | Réponses <2 secondes |
| Composants qui bougent entre pages | Layouts cohérents |
| Tests uniquement sur MacBook 16" | Tests multi-appareils |
| Pas de cache, requêtes répétées | Cache intelligent, optimisation |

## 🎯 **Checklist Rapide**

### **Design**
- [ ] Max 3-4 couleurs cohérentes
- [ ] Emojis avec parcimonie
- [ ] Icônes proportionnées
- [ ] Typographie lisible

### **Interactions**
- [ ] Tous les liens fonctionnent
- [ ] Animations <300ms
- [ ] États de chargement visibles
- [ ] Feedback immédiat

### **Performance**
- [ ] Réponses <2 secondes
- [ ] Tests multi-appareils
- [ ] Layouts cohérents
- [ ] Cache optimisé

## 🚀 **Règles d'Or**

1. **Simplicité > Complexité**
   - 3 variantes de boutons max
   - Animations utiles uniquement
   - Conventions respectées

2. **Utilisateur > Développeur**
   - Tests sur vrais appareils
   - Pratique avant joli
   - Résoudre des problèmes réels

3. **Fonction > Forme**
   - Efficace avant beau
   - Fluidité avant effet wow
   - Lisible avant original

## 📱 **Spécifique à Manounou**

**Utilisateurs** : Parents et nounous de tous âges
**Besoins** : Simplicité, fiabilité, rapidité
**Contexte** : Quotidien chargé, appareils variés

**Priorités** :
1. Lisibilité (contrastes suffisants)
2. Navigation intuitive (conventions)
3. Performance (chargement rapide)
4. Cohérence (même expérience partout)