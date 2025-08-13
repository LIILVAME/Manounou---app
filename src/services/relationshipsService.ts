import { supabase } from '../config/supabase';
import { UserRelationship, RelationshipStatus } from '../types/database';

export interface RelationshipWithUsers extends UserRelationship {
  parent?: {
    id: string;
    display_name: string;
    email: string;
    avatar_url?: string;
  };
  nounou?: {
    id: string;
    display_name: string;
    email: string;
    avatar_url?: string;
  };
}

/**
 * Créer une nouvelle relation entre un parent et une nounou
 */
export const createRelationship = async (
  parentId: string,
  nounouId: string
): Promise<UserRelationship> => {
  const { data, error } = await supabase
    .from('user_relationships')
    .insert({
      parent_id: parentId,
      nounou_id: nounouId,
      status: 'pending' as RelationshipStatus,
    })
    .select()
    .single();

  if (error) {
    throw new Error(
      `Erreur lors de la création de la relation: ${error.message}`
    );
  }

  return data;
};

/**
 * Récupérer les relations d'un utilisateur (parent ou nounou)
 */
export const getUserRelationships = async (
  userId: string,
  userRole: 'parent' | 'nounou'
): Promise<RelationshipWithUsers[]> => {
  const query = supabase.from('user_relationships').select(`
      *,
      parent:users!parent_id(
        id,
        display_name,
        email,
        avatar_url
      ),
      nounou:users!nounou_id(
        id,
        display_name,
        email,
        avatar_url
      )
    `);

  if (userRole === 'parent') {
    query.eq('parent_id', userId);
  } else {
    query.eq('nounou_id', userId);
  }

  const { data, error } = await query.order('created_at', { ascending: false });

  if (error) {
    throw new Error(
      `Erreur lors de la récupération des relations: ${error.message}`
    );
  }

  return data || [];
};

/**
 * Récupérer les demandes de relation en attente pour une nounou
 */
export const getPendingRequests = async (
  nounouId: string
): Promise<RelationshipWithUsers[]> => {
  const { data, error } = await supabase
    .from('user_relationships')
    .select(
      `
      *,
      parent:users!parent_id(
        id,
        display_name,
        email,
        avatar_url
      )
    `
    )
    .eq('nounou_id', nounouId)
    .eq('status', 'pending')
    .order('created_at', { ascending: false });

  if (error) {
    throw new Error(
      `Erreur lors de la récupération des demandes: ${error.message}`
    );
  }

  return data || [];
};

/**
 * Accepter une demande de relation
 */
export const acceptRelationship = async (
  relationshipId: string
): Promise<UserRelationship> => {
  const { data, error } = await supabase
    .from('user_relationships')
    .update({
      status: 'accepted' as RelationshipStatus,
      updated_at: new Date().toISOString(),
    })
    .eq('id', relationshipId)
    .select()
    .single();

  if (error) {
    throw new Error(
      `Erreur lors de l'acceptation de la relation: ${error.message}`
    );
  }

  return data;
};

/**
 * Refuser une demande de relation
 */
export const declineRelationship = async (
  relationshipId: string
): Promise<UserRelationship> => {
  const { data, error } = await supabase
    .from('user_relationships')
    .update({
      status: 'declined' as RelationshipStatus,
      updated_at: new Date().toISOString(),
    })
    .eq('id', relationshipId)
    .select()
    .single();

  if (error) {
    throw new Error(`Erreur lors du refus de la relation: ${error.message}`);
  }

  return data;
};

/**
 * Supprimer une relation
 */
export const deleteRelationship = async (
  relationshipId: string
): Promise<void> => {
  const { error } = await supabase
    .from('user_relationships')
    .delete()
    .eq('id', relationshipId);

  if (error) {
    throw new Error(
      `Erreur lors de la suppression de la relation: ${error.message}`
    );
  }
};

/**
 * Vérifier si une relation existe entre deux utilisateurs
 */
export const checkRelationshipExists = async (
  parentId: string,
  nounouId: string
): Promise<UserRelationship | null> => {
  const { data, error } = await supabase
    .from('user_relationships')
    .select('*')
    .eq('parent_id', parentId)
    .eq('nounou_id', nounouId)
    .single();

  if (error && error.code !== 'PGRST116') {
    // PGRST116 = no rows returned
    throw new Error(
      `Erreur lors de la vérification de la relation: ${error.message}`
    );
  }

  return data || null;
};

/**
 * Récupérer les nounous connectées à un parent
 */
export const getConnectedNounous = async (
  parentId: string
): Promise<RelationshipWithUsers[]> => {
  const { data, error } = await supabase
    .from('user_relationships')
    .select(
      `
      *,
      nounou:users!nounou_id(
        id,
        display_name,
        email,
        avatar_url,
        phone
      )
    `
    )
    .eq('parent_id', parentId)
    .eq('status', 'accepted')
    .order('created_at', { ascending: false });

  if (error) {
    throw new Error(
      `Erreur lors de la récupération des nounous: ${error.message}`
    );
  }

  return data || [];
};

/**
 * Récupérer les parents connectés à une nounou
 */
export const getConnectedParents = async (
  nounouId: string
): Promise<RelationshipWithUsers[]> => {
  const { data, error } = await supabase
    .from('user_relationships')
    .select(
      `
      *,
      parent:users!parent_id(
        id,
        display_name,
        email,
        avatar_url,
        phone
      )
    `
    )
    .eq('nounou_id', nounouId)
    .eq('status', 'accepted')
    .order('created_at', { ascending: false });

  if (error) {
    throw new Error(
      `Erreur lors de la récupération des parents: ${error.message}`
    );
  }

  return data || [];
};

/**
 * Obtenir des statistiques sur les relations
 */
export const getRelationshipStats = async (
  userId: string,
  userRole: 'parent' | 'nounou'
) => {
  const stats = {
    total: 0,
    accepted: 0,
    pending: 0,
    declined: 0,
  };

  const query = supabase.from('user_relationships').select('status');

  if (userRole === 'parent') {
    query.eq('parent_id', userId);
  } else {
    query.eq('nounou_id', userId);
  }

  const { data, error } = await query;

  if (error) {
    throw new Error(
      `Erreur lors de la récupération des statistiques: ${error.message}`
    );
  }

  data?.forEach(relationship => {
    stats.total++;
    const status = relationship.status as RelationshipStatus;
    stats[status]++;
  });

  return stats;
};
