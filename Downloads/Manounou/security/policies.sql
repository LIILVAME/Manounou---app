-- ============================================
-- MANOUNOU - Row Level Security (RLS) & Policies
-- Version: 1.0.0
-- Date: 2025-01-13
-- ============================================

-- Activer Row Level Security sur toutes les tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.children ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;

-- ============================================
-- USERS - Users can access their own profile
-- ============================================
DROP POLICY IF EXISTS "Users can access their own profile" ON public.users;
CREATE POLICY "Users can access their own profile"
ON public.users
FOR ALL
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================
-- CHILDREN - Parents can access their children
-- ============================================
DROP POLICY IF EXISTS "Parents can access their children" ON public.children;
CREATE POLICY "Parents can access their children"
ON public.children
FOR ALL
USING (auth.uid() = parent_id)
WITH CHECK (auth.uid() = parent_id);

-- ============================================
-- EVENTS - Parents can access their events
-- ============================================
DROP POLICY IF EXISTS "Parents can access their events" ON public.events;
CREATE POLICY "Parents can access their events"
ON public.events
FOR ALL
USING (
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id = events.child_id
  )
)
WITH CHECK (
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id = events.child_id
  )
);

-- ============================================
-- DOCUMENTS - Parents can access their documents
-- ============================================
DROP POLICY IF EXISTS "Parents can access their documents" ON public.documents;
CREATE POLICY "Parents can access their documents"
ON public.documents
FOR ALL
USING (
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id = documents.child_id
  )
)
WITH CHECK (
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id = documents.child_id
  )
);

