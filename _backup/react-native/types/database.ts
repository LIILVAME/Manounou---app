export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          email: string;
          display_name: string;
          role: 'parent' | 'nounou' | 'admin';
          plan: 'free' | 'starter' | 'full';
          avatar_url?: string;
          phone?: string;
          address?: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          email: string;
          display_name: string;
          role: 'parent' | 'nounou' | 'admin';
          plan?: 'free' | 'starter' | 'full';
          avatar_url?: string;
          phone?: string;
          address?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          email?: string;
          display_name?: string;
          role?: 'parent' | 'nounou' | 'admin';
          plan?: 'free' | 'starter' | 'full';
          avatar_url?: string;
          phone?: string;
          address?: string;
          created_at?: string;
          updated_at?: string;
        };
      };
      children: {
        Row: {
          id: string;
          parent_id: string;
          first_name: string;
          last_name: string;
          birth_date: string;
          allergies?: string;
          medical_notes?: string;
          emergency_contact?: string;
          avatar_url?: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          parent_id: string;
          first_name: string;
          last_name: string;
          birth_date: string;
          allergies?: string;
          medical_notes?: string;
          emergency_contact?: string;
          avatar_url?: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          parent_id?: string;
          first_name?: string;
          last_name?: string;
          birth_date?: string;
          allergies?: string;
          medical_notes?: string;
          emergency_contact?: string;
          avatar_url?: string;
          created_at?: string;
          updated_at?: string;
        };
      };
      events: {
        Row: {
          id: string;
          child_id: string;
          title: string;
          description?: string;
          event_type:
            | 'garde'
            | 'activite'
            | 'medical'
            | 'repas'
            | 'sommeil'
            | 'autre';
          start_time: string;
          end_time: string;
          all_day: boolean;
          location?: string;
          notes?: string;
          created_by: string;
          status: 'confirmed' | 'pending' | 'cancelled';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          child_id: string;
          title: string;
          description?: string;
          event_type:
            | 'garde'
            | 'activite'
            | 'medical'
            | 'repas'
            | 'sommeil'
            | 'autre';
          start_time: string;
          end_time: string;
          all_day?: boolean;
          location?: string;
          notes?: string;
          created_by: string;
          status?: 'confirmed' | 'pending' | 'cancelled';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          child_id?: string;
          title?: string;
          description?: string;
          event_type?:
            | 'garde'
            | 'activite'
            | 'medical'
            | 'repas'
            | 'sommeil'
            | 'autre';
          start_time?: string;
          end_time?: string;
          all_day?: boolean;
          location?: string;
          notes?: string;
          created_by?: string;
          status?: 'confirmed' | 'pending' | 'cancelled';
          created_at?: string;
          updated_at?: string;
        };
      };
      documents: {
        Row: {
          id: string;
          child_id: string;
          title: string;
          description?: string;
          file_url: string;
          file_type: string;
          file_size: number;
          category: 'medical' | 'administratif' | 'photo' | 'autre';
          uploaded_by: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          child_id: string;
          title: string;
          description?: string;
          file_url: string;
          file_type: string;
          file_size: number;
          category: 'medical' | 'administratif' | 'photo' | 'autre';
          uploaded_by: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          child_id?: string;
          title?: string;
          description?: string;
          file_url?: string;
          file_type?: string;
          file_size?: number;
          category?: 'medical' | 'administratif' | 'photo' | 'autre';
          uploaded_by?: string;
          created_at?: string;
          updated_at?: string;
        };
      };
      user_relationships: {
        Row: {
          id: string;
          parent_id: string;
          nounou_id: string;
          status: 'pending' | 'accepted' | 'declined';
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          parent_id: string;
          nounou_id: string;
          status?: 'pending' | 'accepted' | 'declined';
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          id?: string;
          parent_id?: string;
          nounou_id?: string;
          status?: 'pending' | 'accepted' | 'declined';
          created_at?: string;
          updated_at?: string;
        };
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      [_ in never]: never;
    };
    Enums: {
      user_role: 'parent' | 'nounou' | 'admin';
      user_plan: 'free' | 'starter' | 'full';
      event_type:
        | 'garde'
        | 'activite'
        | 'medical'
        | 'repas'
        | 'sommeil'
        | 'autre';
      event_status: 'confirmed' | 'pending' | 'cancelled';
      document_category: 'medical' | 'administratif' | 'photo' | 'autre';
      relationship_status: 'pending' | 'accepted' | 'declined';
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
}

export type User = Database['public']['Tables']['users']['Row'];
export type Child = Database['public']['Tables']['children']['Row'];
export type Event = Database['public']['Tables']['events']['Row'];
export type Document = Database['public']['Tables']['documents']['Row'];
export type UserRelationship =
  Database['public']['Tables']['user_relationships']['Row'];

export type UserRole = Database['public']['Enums']['user_role'];
export type UserPlan = Database['public']['Enums']['user_plan'];
export type EventType = Database['public']['Enums']['event_type'];
export type EventStatus = Database['public']['Enums']['event_status'];
export type DocumentCategory = Database['public']['Enums']['document_category'];
export type RelationshipStatus =
  Database['public']['Enums']['relationship_status'];
