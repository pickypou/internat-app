-- Table: attendance_history
-- Description: Boîte Noire de l'internat (Archivage Légal).
-- Seules les insertions (lors de la clôture) et les lectures (pour PDF) sont autorisées.
-- Aucune modification ou suppression raturable n'est permise.

CREATE TABLE public.attendance_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Foreign keys (nullable in case of deletion, but data is copied below)
    student_id UUID REFERENCES public.students(id) ON DELETE SET NULL,
    group_id UUID REFERENCES public.groups(id) ON DELETE SET NULL,
    
    -- Copies en dur (figées au moment de l'archivage)
    stored_last_name TEXT NOT NULL,
    stored_first_name TEXT NOT NULL,
    stored_class_name TEXT NOT NULL,
    stored_room_number TEXT NOT NULL,
    
    -- Informations de présence
    check_date DATE NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('Présent', 'Absent', 'Stage', 'Hors Quinzaine')),
    note TEXT,
    
    -- Horodatage serveur de l'archivage
    archive_date TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.attendance_history ENABLE ROW LEVEL SECURITY;

-- Policy: Select (Lecture autorisée pour tous les utilisateurs authentifiés)
CREATE POLICY "Allow read access for authenticated users" 
ON public.attendance_history
FOR SELECT
TO authenticated
USING (true);

-- Policy: Insert (Insertion autorisée pour tous les utilisateurs authentifiés)
CREATE POLICY "Allow insert access for authenticated users" 
ON public.attendance_history
FOR INSERT
TO authenticated
WITH CHECK (true);

-- /!\ Aucune politique pour UPDATE et DELETE n'est créée /!\
-- Cela garantit une "Boîte Noire" inviolable.
