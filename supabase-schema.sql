-- ════════════════════════════════════════════════════════════════
--  ResSync — Schéma Supabase complet
--  À exécuter dans Supabase → SQL Editor
-- ════════════════════════════════════════════════════════════════

-- ── Profils LOVE ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles_love (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    name        TEXT NOT NULL DEFAULT '',
    age         INT  NOT NULL DEFAULT 18,
    nationality TEXT NOT NULL DEFAULT '',
    bio         TEXT NOT NULL DEFAULT '',
    interests   TEXT[] NOT NULL DEFAULT '{}',
    photos      TEXT[] NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles_love ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lecture publique love"  ON profiles_love FOR SELECT USING (true);
CREATE POLICY "Écriture owner love"    ON profiles_love FOR ALL   USING (auth.uid() = user_id);

-- ── Profils WORK ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles_work (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    name        TEXT NOT NULL DEFAULT '',
    job_title   TEXT NOT NULL DEFAULT '',
    company     TEXT NOT NULL DEFAULT '',
    bio_pro     TEXT NOT NULL DEFAULT '',
    skills      TEXT[] NOT NULL DEFAULT '{}',
    photo       TEXT NOT NULL DEFAULT '',
    created_at  TIMESTAMPTZ DEFAULT NOW(),
    updated_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE profiles_work ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lecture publique work"  ON profiles_work FOR SELECT USING (true);
CREATE POLICY "Écriture owner work"    ON profiles_work FOR ALL   USING (auth.uid() = user_id);

-- ── Participants d'un trajet ──────────────────────────────────────
CREATE TABLE IF NOT EXISTS trip_participants (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id     TEXT NOT NULL,
    user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    mode        TEXT NOT NULL CHECK (mode IN ('love', 'work')),
    joined_at   TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(trip_id, user_id)
);

ALTER TABLE trip_participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lecture participants" ON trip_participants FOR SELECT USING (true);
CREATE POLICY "Écriture participant" ON trip_participants FOR INSERT USING (auth.uid() = user_id);
CREATE POLICY "Mise à jour participant" ON trip_participants FOR UPDATE USING (auth.uid() = user_id);

-- ── Réactions entre profils ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS profile_reactions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id      TEXT NOT NULL,
    from_user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    to_user_id   UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    reaction     TEXT NOT NULL CHECK (reaction IN ('wave', 'coffee', 'chat')),
    created_at   TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(trip_id, from_user_id, to_user_id, reaction)
);

ALTER TABLE profile_reactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Lecture réactions" ON profile_reactions FOR SELECT
    USING (auth.uid() = from_user_id OR auth.uid() = to_user_id);
CREATE POLICY "Envoi réaction"    ON profile_reactions FOR INSERT USING (auth.uid() = from_user_id);

-- ── Trigger updated_at automatique ───────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at_love
    BEFORE UPDATE ON profiles_love
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at_work
    BEFORE UPDATE ON profiles_work
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Index pour les performances ───────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_trip_participants_trip  ON trip_participants(trip_id);
CREATE INDEX IF NOT EXISTS idx_trip_participants_user  ON trip_participants(user_id);
CREATE INDEX IF NOT EXISTS idx_reactions_to_user       ON profile_reactions(to_user_id);
