-- M0 (suite) : la révocation précédente a retiré les grants explicites anon/
-- authenticated mais la fonction conservait le grant EXECUTE implicite à PUBLIC
-- (dont anon/authenticated héritent). On révoque EXECUTE à PUBLIC pour réellement
-- lever les advisors 0028/0029. postgres et service_role gardent leur grant
-- explicite ; le comportement event-trigger reste intact.
--
-- Vérifié : has_function_privilege('anon'|'authenticated', oid, 'EXECUTE') = false,
-- service_role = true.
revoke execute on function public.rls_auto_enable() from public, anon, authenticated;
