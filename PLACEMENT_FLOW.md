# Placement & Pickup Flow (Automotive)

## Pickup (Task → Scan → Placement End)
1. Task öffnen → zeigt Halle → Station → Stand → Material, Fortschritt `0 / N`.
2. [Box scannen] → QR lesen.
3. Validierung: Box liegt am erwarteten Stand (`task_pickup_items`), noch nicht gescannt, Slot offen.
4. Platzierung endet (`box_placements.removed_at` gesetzt), Scan protokolliert (`task_pickup_scans`).
5. Fortschritt +1; wenn alle Anforderungen erfüllt → Task-Status → `PICKED_UP`.

## Placement (Stand → Box)
1. Stand scannen/auswählen → freie Slots + Material anzeigen.
2. [Box hinzufügen] → QR scannen.
3. Checks: Box frei (keine aktive Platzierung), Stand nicht voll (`activePlacements < max_slots`).
4. Platzierung anlegen (`box_placements`), Box-Status `AT_STAND`, Audit/Activity schreiben.
5. UI zeigt aktive Boxen + verbleibende Slots.

## Admin Wizard (Umbauten & Änderungen)
1. Halle wählen → Stationen verwalten (Verschieben nur in aktive Hallen).
2. Stand anpassen → Material, `max_slots`, Deaktivieren nur wenn leer (keine aktiven Placements).
3. Box-Status prüfen → aktueller Standort oder „unterwegs“, Konflikte anzeigen (keine Doppel-Platzierungen).
4. Jede Änderung erzeugt `activity_logs` + Audit; keine impliziten Überschreibungen (erst entfernen, dann neu platzieren).
