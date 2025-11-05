-- ============================================
-- MANOUNOU - RLS Policies pour Schedules
-- Version: 1.0.0
-- Date: 2025-01-13
-- ============================================

-- Activer Row Level Security
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_items ENABLE ROW LEVEL SECURITY;

-- ============================================
-- SCHEDULES - Parents can access their children's schedules
-- ============================================
DROP POLICY IF EXISTS "Parents can access their children's schedules" ON public.schedules;
CREATE POLICY "Parents can access their children's schedules"
ON public.schedules
FOR ALL
USING (
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id = schedules.child_id
  )
)
WITH CHECK (
  auth.uid() IN (
    SELECT parent_id 
    FROM public.children 
    WHERE id = schedules.child_id
  )
);

-- ============================================
-- SCHEDULE_ITEMS - Parents can access schedule items
-- ============================================
DROP POLICY IF EXISTS "Parents can access schedule items" ON public.schedule_items;
CREATE POLICY "Parents can access schedule items"
ON public.schedule_items
FOR ALL
USING (
  auth.uid() IN (
    SELECT c.parent_id 
    FROM public.children c
    INNER JOIN public.schedules s ON c.id = s.child_id
    WHERE s.id = schedule_items.schedule_id
  )
)
WITH CHECK (
  auth.uid() IN (
    SELECT c.parent_id 
    FROM public.children c
    INNER JOIN public.schedules s ON c.id = s.child_id
    WHERE s.id = schedule_items.schedule_id
  )
);

