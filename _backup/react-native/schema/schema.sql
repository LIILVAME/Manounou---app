-- Manounou Database Schema
-- Created for Supabase PostgreSQL

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable RLS (Row Level Security)
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Profiles table
CREATE TABLE public.profiles (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE PRIMARY KEY,
    role TEXT NOT NULL CHECK (role IN ('parent', 'nanny', 'admin')),
    display_name TEXT NOT NULL,
    language TEXT NOT NULL DEFAULT 'fr' CHECK (language IN ('fr', 'en')),
    photo_url TEXT,
    plan TEXT NOT NULL DEFAULT 'free' CHECK (plan IN ('free', 'starter', 'full')),
    plan_status TEXT NOT NULL DEFAULT 'active' CHECK (plan_status IN ('active', 'past_due', 'canceled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Children table
CREATE TABLE public.children (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    parent_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    full_name TEXT NOT NULL,
    date_of_birth DATE NOT NULL,
    allergies TEXT,
    notes TEXT,
    photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Events table
CREATE TABLE public.events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    child_id UUID REFERENCES public.children(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('activity', 'meal', 'nap', 'outing', 'vacation')),
    title TEXT NOT NULL,
    start_at TIMESTAMP WITH TIME ZONE NOT NULL,
    end_at TIMESTAMP WITH TIME ZONE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT valid_time_range CHECK (end_at > start_at)
);

-- Documents table
CREATE TABLE public.documents (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    child_id UUID REFERENCES public.children(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    file_url TEXT NOT NULL,
    mime_type TEXT NOT NULL,
    file_size INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Subscriptions table (for Stripe integration)
CREATE TABLE public.subscriptions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    stripe_customer_id TEXT UNIQUE,
    stripe_subscription_id TEXT UNIQUE,
    plan TEXT NOT NULL CHECK (plan IN ('free', 'starter', 'full')),
    status TEXT NOT NULL CHECK (status IN ('active', 'past_due', 'canceled', 'incomplete', 'trialing')),
    current_period_start TIMESTAMP WITH TIME ZONE,
    current_period_end TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit logs table
CREATE TABLE public.audit_logs (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity TEXT NOT NULL,
    entity_id UUID,
    meta JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_profiles_user_id ON public.profiles(user_id);
CREATE INDEX idx_children_parent_id ON public.children(parent_id);
CREATE INDEX idx_events_owner_id ON public.events(owner_id);
CREATE INDEX idx_events_child_id ON public.events(child_id);
CREATE INDEX idx_events_start_at ON public.events(start_at);
CREATE INDEX idx_documents_owner_id ON public.documents(owner_id);
CREATE INDEX idx_documents_child_id ON public.documents(child_id);
CREATE INDEX idx_subscriptions_user_id ON public.subscriptions(user_id);
CREATE INDEX idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON public.audit_logs(created_at);

-- Functions for updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_children_updated_at BEFORE UPDATE ON public.children FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON public.events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON public.documents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.children ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.users FOR UPDATE USING (auth.uid() = id);

-- Profiles policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Children policies
CREATE POLICY "Parents can manage their children" ON public.children FOR ALL USING (auth.uid() = parent_id);
CREATE POLICY "Nannies can view children they care for" ON public.children FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.events e 
        WHERE e.child_id = children.id 
        AND e.owner_id = auth.uid()
    )
);

-- Events policies
CREATE POLICY "Users can manage their own events" ON public.events FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "Parents can view events for their children" ON public.events FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.children c 
        WHERE c.id = events.child_id 
        AND c.parent_id = auth.uid()
    )
);

-- Documents policies
CREATE POLICY "Users can manage their own documents" ON public.documents FOR ALL USING (auth.uid() = owner_id);
CREATE POLICY "Parents can view documents for their children" ON public.documents FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.children c 
        WHERE c.id = documents.child_id 
        AND c.parent_id = auth.uid()
    )
);

-- Subscriptions policies
CREATE POLICY "Users can view own subscription" ON public.subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own subscription" ON public.subscriptions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own subscription" ON public.subscriptions FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Audit logs policies (admin only for full access, users can see their own)
CREATE POLICY "Users can view own audit logs" ON public.audit_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can view all audit logs" ON public.audit_logs FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.profiles p 
        WHERE p.user_id = auth.uid() 
        AND p.role = 'admin'
    )
);

-- Functions for business logic
CREATE OR REPLACE FUNCTION get_user_plan_limits(user_uuid UUID)
RETURNS TABLE(
    max_children INTEGER,
    max_documents INTEGER,
    max_events_per_day INTEGER
) AS $$
DECLARE
    user_plan TEXT;
BEGIN
    SELECT plan INTO user_plan FROM public.profiles WHERE user_id = user_uuid;
    
    CASE user_plan
        WHEN 'free' THEN
            RETURN QUERY SELECT 1, 3, 10;
        WHEN 'starter' THEN
            RETURN QUERY SELECT 3, 20, 50;
        WHEN 'full' THEN
            RETURN QUERY SELECT -1, -1, -1; -- -1 means unlimited
        ELSE
            RETURN QUERY SELECT 1, 3, 10; -- default to free
    END CASE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check plan limits before insert
CREATE OR REPLACE FUNCTION check_plan_limits()
RETURNS TRIGGER AS $$
DECLARE
    limits RECORD;
    current_count INTEGER;
BEGIN
    SELECT * INTO limits FROM get_user_plan_limits(NEW.parent_id);
    
    IF TG_TABLE_NAME = 'children' THEN
        IF limits.max_children != -1 THEN
            SELECT COUNT(*) INTO current_count FROM public.children WHERE parent_id = NEW.parent_id;
            IF current_count >= limits.max_children THEN
                RAISE EXCEPTION 'Plan limit exceeded: maximum % children allowed', limits.max_children;
            END IF;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for plan limits
CREATE TRIGGER check_children_plan_limits
    BEFORE INSERT ON public.children
    FOR EACH ROW EXECUTE FUNCTION check_plan_limits();

-- Initial data
INSERT INTO public.users (id, email) VALUES 
    ('00000000-0000-0000-0000-000000000001', 'parent_test@manounou.com'),
    ('00000000-0000-0000-0000-000000000002', 'nanny_test@manounou.com')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (user_id, role, display_name, language, plan) VALUES 
    ('00000000-0000-0000-0000-000000000001', 'parent', 'Parent Test', 'fr', 'starter'),
    ('00000000-0000-0000-0000-000000000002', 'nanny', 'Nounou Test', 'fr', 'free')
ON CONFLICT (user_id) DO NOTHING;