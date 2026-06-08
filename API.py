import requests
from datetime import datetime, timedelta
import time
import pandas as pd
import sys
from supabase import create_client, Client

# ─────────────────────────────────────────────
#  CONFIGURATION
# ─────────────────────────────────────────────
SNCF_API_KEY = "57f5491f-525d-4dc2-a867-e9cfab1738d3"

SUPABASE_URL = "https://zrtsionwgtgtcbnylvgs.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpydHNpb253Z3RndGNibnlsdmdzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5NDc0NCwiZXhwIjoyMDkxNjcwNzQ0fQ.ofEFtgek3yXCrOR8ZK8DlEgCdi1P6nFYzXPd0odUSs0"

BASE_URL = "https://api.sncf.com/v1/coverage/sncf"

GARES_TGV = {
    # --- PARIS ET ÎLE-DE-FRANCE ---
    "Paris Gare de Lyon":                    "stop_area:SNCF:87686006",
    "Paris Montparnasse":                    "stop_area:SNCF:87391003",
    "Paris Nord":                            "stop_area:SNCF:87271007",
    "Paris Est":                             "stop_area:SNCF:87113001",
    "Paris Austerlitz":                      "stop_area:SNCF:87547000",
    "Paris Bercy Bourgogne-Pays d'Auvergne": "stop_area:SNCF:87686667",
    "Marne-la-Vallée–Chessy":               "stop_area:SNCF:87213027",
    "Massy TGV":                             "stop_area:SNCF:87393509",
    "Aéroport Charles-de-Gaulle 2 TGV":     "stop_area:SNCF:87271460",
    # --- SUD-EST ---
    "Lyon Part-Dieu":                        "stop_area:SNCF:87723197",
    "Lyon Perrache":                         "stop_area:SNCF:87722025",
    "Lyon Saint-Exupéry TGV":               "stop_area:SNCF:87725002",
    "Marseille Saint-Charles":               "stop_area:SNCF:87751008",
    "Aix-en-Provence TGV":                   "stop_area:SNCF:87751453",
    "Avignon TGV":                           "stop_area:SNCF:87318961",
    "Valence TGV Rhône-Alpes Sud":           "stop_area:SNCF:87142101",
    "Nice Ville":                            "stop_area:SNCF:87756007",
    "Cannes":                                "stop_area:SNCF:87757005",
    "Antibes":                               "stop_area:SNCF:87757229",
    "Toulon":                                "stop_area:SNCF:87758003",
    "Montpellier Saint-Roch":                "stop_area:SNCF:87773002",
    "Montpellier Sud de France":             "stop_area:SNCF:87319001",
    "Nîmes Centre":                          "stop_area:SNCF:87775007",
    "Nîmes Pont-du-Gard":                    "stop_area:SNCF:87116665",
    "Perpignan":                             "stop_area:SNCF:87784009",
    "Grenoble":                              "stop_area:SNCF:87747006",
    "Saint-Étienne Châteaucreux":            "stop_area:SNCF:87726000",
    # --- SUD-OUEST ---
    "Bordeaux Saint-Jean":                   "stop_area:SNCF:87581009",
    "Toulouse Matabiau":                     "stop_area:SNCF:87611004",
    "Bayonne":                               "stop_area:SNCF:87671008",
    "Biarritz":                              "stop_area:SNCF:87671024",
    "Hendaye":                               "stop_area:SNCF:87671107",
    "Pau":                                   "stop_area:SNCF:87674002",
    "La Rochelle Ville":                     "stop_area:SNCF:87542001",
    "Angoulême":                             "stop_area:SNCF:87485003",
    "Agen":                                  "stop_area:SNCF:87586008",
    # --- OUEST ---
    "Nantes":                                "stop_area:SNCF:87481002",
    "Rennes":                                "stop_area:SNCF:87471003",
    "Angers Saint-Laud":                     "stop_area:SNCF:87484006",
    "Le Mans":                               "stop_area:SNCF:87391102",
    "Brest":                                 "stop_area:SNCF:87474007",
    "Quimper":                               "stop_area:SNCF:87474171",
    "Lorient":                               "stop_area:SNCF:87474031",
    "Vannes":                                "stop_area:SNCF:87474106",
    "Saint-Nazaire":                         "stop_area:SNCF:87481168",
    # --- NORD ---
    "Lille Europe":                          "stop_area:SNCF:87223263",
    "Lille Flandres":                        "stop_area:SNCF:87223008",
    "Arras":                                 "stop_area:SNCF:87211005",
    "Dunkerque":                             "stop_area:SNCF:87225003",
    "Calais-Fréthun":                        "stop_area:SNCF:87221002",
    "Valenciennes":                          "stop_area:SNCF:87271452",
    # --- EST ---
    "Strasbourg":                            "stop_area:SNCF:87212027",
    "Metz Ville":                            "stop_area:SNCF:87191001",
    "Nancy Ville":                           "stop_area:SNCF:87141002",
    "Reims":                                 "stop_area:SNCF:87171003",
    "Champagne-Ardenne TGV":                 "stop_area:SNCF:87171722",
    "Lorraine TGV":                          "stop_area:SNCF:87141010",
    "Dijon Ville":                           "stop_area:SNCF:87713000",
    "Mulhouse Ville":                        "stop_area:SNCF:87182000",
    "Colmar":                                "stop_area:SNCF:87181002",
    "Besançon Franche-Comté TGV":            "stop_area:SNCF:87711012",
    "Belfort-Montbéliard TGV":              "stop_area:SNCF:87711020",
    # --- CENTRE ---
    "Tours":                                 "stop_area:SNCF:87571000",
    "Saint-Pierre-des-Corps":               "stop_area:SNCF:87571026",
    "Orléans Centre":                        "stop_area:SNCF:87543009",
    "Le Creusot-Montceau TGV":              "stop_area:SNCF:87691345",
    "Mâcon-Loché TGV":                      "stop_area:SNCF:87694000",
}

# Index inversé : stop_area_id → nom de la gare (pour identifier les arrêts TGV dans un vehicle_journey)
ID_TO_GARE = {v: k for k, v in GARES_TGV.items()}

COMMERCIAL_MODES_TGV = {"TGV", "TGV INOUI", "INOUI", "OUIGO"}

# ─────────────────────────────────────────────
#  OUTILS
# ─────────────────────────────────────────────
def parse_dt(dt_str):
    if not dt_str:
        return None
    try:
        return datetime.strptime(dt_str, "%Y%m%dT%H%M%S")
    except Exception:
        return None

def fmt_dt(dt):
    return dt.strftime("%d/%m/%Y %H:%M") if dt else "—"

def get_session():
    s = requests.Session()
    s.auth = (SNCF_API_KEY, "")
    s.headers.update({"Accept": "application/json"})
    return s

# ─────────────────────────────────────────────
#  ÉTAPE 1 — Récupérer les départs depuis une gare
# ─────────────────────────────────────────────
def fetch_departures(session, stop_area_id, gare_name, dt_from, duration_sec=86400):
    """Retourne la liste des vehicle_journey_id des TGV qui partent de cette gare."""
    url = f"{BASE_URL}/stop_areas/{stop_area_id}/departures"
    params = {
        "from_datetime": dt_from.strftime("%Y%m%dT%H%M%S"),
        "duration": duration_sec,
        "count": 200,
        "data_freshness": "base_schedule",
    }

    try:
        resp = session.get(url, params=params, timeout=15)
        resp.raise_for_status()
    except Exception as e:
        print(f"  ⚠ Erreur API départs pour {gare_name} : {e}")
        return []

    deps = resp.json().get("departures", [])
    vj_ids = []

    for dep in deps:
        line = dep.get("route", {}).get("line", {})
        mode = line.get("commercial_mode", {}).get("name", "").upper()
        if not any(m in mode for m in COMMERCIAL_MODES_TGV):
            continue

        links = dep.get("links", [])
        vj_id = next((l["id"] for l in links if l.get("type") == "vehicle_journey"), None)
        if vj_id:
            info = dep.get("display_informations", {})
            vj_ids.append({
                "vj_id": vj_id,
                "train_number": info.get("trip_short_name") or info.get("headsign", "?"),
                "transport_type": mode,
            })

    return vj_ids

# ─────────────────────────────────────────────
#  ÉTAPE 2 — Décomposer un vehicle_journey en paires de gares TGV
# ─────────────────────────────────────────────
def fetch_vehicle_journey_pairs(session, vj_id, train_number, transport_type):
    """
    Récupère tous les arrêts du train et génère une ligne de cache pour chaque
    paire (gare_TGV_i → gare_TGV_j) avec i < j (sens de circulation).
    """
    url = f"{BASE_URL}/vehicle_journeys/{vj_id}"
    try:
        resp = session.get(url, timeout=15)
        resp.raise_for_status()
    except Exception as e:
        print(f"    ⚠ Erreur vehicle_journey {vj_id} : {e}")
        return []

    vjs = resp.json().get("vehicle_journeys", [])
    if not vjs:
        return []

    stop_times = vjs[0].get("stop_times", [])

    # Ne garder que les arrêts qui correspondent à une gare TGV connue
    tgv_stops = []
    for st in stop_times:
        sa = st.get("stop_point", {}).get("stop_area", {})
        sa_id = sa.get("id", "")
        # Normaliser : stop_area id peut être sous forme "stop_area:SNCF:XXXXXXX"
        # ou parfois juste "SNCF:XXXXXXX" selon la version
        if sa_id not in ID_TO_GARE:
            sa_id_alt = f"stop_area:{sa_id}" if not sa_id.startswith("stop_area:") else sa_id
            if sa_id_alt not in ID_TO_GARE:
                continue
            sa_id = sa_id_alt

        dep_dt = parse_dt(st.get("departure_time") or st.get("arrival_time"))
        if dep_dt is None:
            continue

        tgv_stops.append({
            "gare_name": ID_TO_GARE[sa_id],
            "dt": dep_dt,
        })

    # Générer toutes les paires (i, j) avec i < j
    records = []
    for i in range(len(tgv_stops)):
        for j in range(i + 1, len(tgv_stops)):
            origin = tgv_stops[i]
            dest   = tgv_stops[j]
            records.append({
                "train_number":    train_number,
                "transport_type":  transport_type,
                "origin":          origin["gare_name"],
                "destination":     dest["gare_name"],
                "departure_time":  origin["dt"].isoformat(),
                "arrival_time":    dest["dt"].isoformat(),
            })

    return records

# ─────────────────────────────────────────────
#  PROGRAMME PRINCIPAL
# ─────────────────────────────────────────────
def main():
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    session = get_session()

    jours = 15
    maintenant = datetime.now()

    print("=" * 70)
    print(f"MAJ CACHE TGV — {jours} jours à partir de {fmt_dt(maintenant)}")
    print("=" * 70)

    tous_les_records = []
    # Garder en mémoire les vehicle_journey déjà traités pour éviter les doublons
    vj_traites = set()

    for j in range(jours):
        dt = maintenant + timedelta(days=j)
        print(f"\n📅 Jour {j+1}/{jours} — {dt.strftime('%d/%m/%Y')}")

        for gare_name, stop_id in GARES_TGV.items():
            vj_list = fetch_departures(session, stop_id, gare_name, dt)
            time.sleep(0.1)

            for vj_info in vj_list:
                vj_id = vj_info["vj_id"]
                if vj_id in vj_traites:
                    continue
                vj_traites.add(vj_id)

                pairs = fetch_vehicle_journey_pairs(
                    session,
                    vj_id,
                    vj_info["train_number"],
                    vj_info["transport_type"],
                )
                tous_les_records.extend(pairs)
                time.sleep(0.15)

    if not tous_les_records:
        print("\n❌ Aucun trajet trouvé.")
        return

    df = pd.DataFrame(tous_les_records)
    df = df.drop_duplicates(subset=["train_number", "origin", "destination", "departure_time"])
    records = df.to_dict("records")

    print(f"\n🚀 Envoi de {len(records)} trajets vers Supabase...")

    try:
        # Vider l'ancien cache avant d'insérer les nouvelles données
        supabase.table("tgv_schedules").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
        print("  🗑  Ancien cache supprimé.")

        batch_size = 500
        for i in range(0, len(records), batch_size):
            batch = records[i:i + batch_size]
            supabase.table("tgv_schedules").insert(batch).execute()
            print(f"  ✅ Batch {i // batch_size + 1} — {len(batch)} records")

        print("\n✨ MISE À JOUR RÉUSSIE !")
    except Exception as e:
        print(f"\n❌ Erreur Supabase : {e}")

    print("=" * 70)

if __name__ == "__main__":
    main()
