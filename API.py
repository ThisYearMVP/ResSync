import requests
from datetime import datetime, timedelta
from tabulate import tabulate
import time
import sys
import os
from supabase import create_client, Client

# ─────────────────────────────────────────────
#  CONFIGURATION (À REMPLIR)
# ─────────────────────────────────────────────
# Clé API SNCF (Navitia)
SNCF_API_KEY = "57f5491f-525d-4dc2-a867-e9cfab1738d3"

# Identifiants Supabase (Projet > Settings > API)
SUPABASE_URL = "https://zrtsionwgtgtcbnylvgs.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpydHNpb253Z3RndGNibnlsdmdzIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA5NDc0NCwiZXhwIjoyMDkxNjcwNzQ0fQ.ofEFtgek3yXCrOR8ZK8DlEgCdi1P6nFYzXPd0odUSs0"
# URL de base SNCF
BASE_URL = "https://api.sncf.com/v1/coverage/sncf"

# Principales gares TGV
GARES_TGV = {"Paris Gare de Lyon": "stop_area:SNCF:87686006",
    "Paris Montparnasse": "stop_area:SNCF:87391003",
    "Paris Nord": "stop_area:SNCF:87271007",
    "Paris Est": "stop_area:SNCF:87113001",
    "Paris Austerlitz": "stop_area:SNCF:87547000",
    "Marne-la-Vallée–Chessy": "stop_area:SNCF:87213027",
    "Massy TGV": "stop_area:SNCF:87393509",
    "Aéroport Charles-de-Gaulle 2 TGV": "stop_area:SNCF:87271460",
    "Strasbourg": "stop_area:SNCF:87212027",
    "Mulhouse": "stop_area:SNCF:87182002",
    "Colmar": "stop_area:SNCF:87182014",
    "Sélestat": "stop_area:SNCF:87214003",
    "Saverne": "stop_area:SNCF:87214061",
    "Metz": "stop_area:SNCF:87192002",
    "Nancy": "stop_area:SNCF:87141002",
    "Épinal": "stop_area:SNCF:87184002",
    "Remiremont": "stop_area:SNCF:87184509",
    "Charleville-Mézières": "stop_area:SNCF:87174002",
    "Sedan": "stop_area:SNCF:87174019",
    "Reims": "stop_area:SNCF:87172002",
    "Champagne-Ardenne TGV": "stop_area:SNCF:87172040",
    "Châlons-en-Champagne": "stop_area:SNCF:87172019",
    "Troyes": "stop_area:SNCF:87171009",
    "Lille Europe": "stop_area:SNCF:87223263",
    "Lille Flandres": "stop_area:SNCF:87223000",
    "Arras": "stop_area:SNCF:87284008",
    "Douai": "stop_area:SNCF:87285005",
    "Valenciennes": "stop_area:SNCF:87295005",
    "Dunkerque": "stop_area:SNCF:87281006",
    "Calais-Fréthun": "stop_area:SNCF:87281007",
    "Boulogne-Ville": "stop_area:SNCF:87281002",
    "Amiens": "stop_area:SNCF:87318003",
    "Rennes": "stop_area:SNCF:87471003",
    "Saint-Malo": "stop_area:SNCF:87471400",
    "Brest": "stop_area:SNCF:87471007",
    "Quimper": "stop_area:SNCF:87474002",
    "Lorient": "stop_area:SNCF:87473003",
    "Vannes": "stop_area:SNCF:87473002",
    "Saint-Brieuc": "stop_area:SNCF:87472006",
    "Morlaix": "stop_area:SNCF:87471009",
    "Nantes": "stop_area:SNCF:87481002",
    "Angers Saint-Laud": "stop_area:SNCF:87487003",
    "Le Mans": "stop_area:SNCF:87391003",
    "Laval": "stop_area:SNCF:87478000",
    "La Roche-sur-Yon": "stop_area:SNCF:87484006",
    "Les Sables-d'Olonne": "stop_area:SNCF:87484203",
    "Tours": "stop_area:SNCF:87571000",
    "Saint-Pierre-des-Corps": "stop_area:SNCF:87571500",
    "Blois": "stop_area:SNCF:87575003",
    "Orléans": "stop_area:SNCF:87543000",
    "Vierzon": "stop_area:SNCF:87575008",
    "Bourges": "stop_area:SNCF:87575009",
    "Châteauroux": "stop_area:SNCF:87547000",
    "Bordeaux Saint-Jean": "stop_area:SNCF:87581009",
    "Poitiers": "stop_area:SNCF:87575001",
    "Angoulême": "stop_area:SNCF:87575002",
    "Libourne": "stop_area:SNCF:87581001",
    "Arcachon": "stop_area:SNCF:87581003",
    "Hendaye": "stop_area:SNCF:87672006",
    "Bayonne": "stop_area:SNCF:87672002",
    "Biarritz": "stop_area:SNCF:87672003",
    "Dax": "stop_area:SNCF:87672004",
    "Pau": "stop_area:SNCF:87672005",
    "Tarbes": "stop_area:SNCF:87672007",
    "La Rochelle": "stop_area:SNCF:87575004",
    "Niort": "stop_area:SNCF:87575005",
    "Saintes": "stop_area:SNCF:87575006",
    "Limoges": "stop_area:SNCF:87594000",
    "Brive-la-Gaillarde": "stop_area:SNCF:87594001",
    "Toulouse Matabiau": "stop_area:SNCF:87611004",
    "Montauban": "stop_area:SNCF:87611005",
    "Agen": "stop_area:SNCF:87611006",
    "Cahors": "stop_area:SNCF:87611007",
    "Montpellier Saint-Roch": "stop_area:SNCF:87773002",
    "Montpellier Sud-de-France": "stop_area:SNCF:87773400",
    "Nîmes": "stop_area:SNCF:87775007",
    "Nîmes Pont-du-Gard": "stop_area:SNCF:87775008",
    "Béziers": "stop_area:SNCF:87775009",
    "Narbonne": "stop_area:SNCF:87775010",
    "Perpignan": "stop_area:SNCF:87775011",
    "Carcassonne": "stop_area:SNCF:87611008",
    "Sète": "stop_area:SNCF:87775012",
    "Lyon Part-Dieu": "stop_area:SNCF:87723197",
    "Lyon Perrache": "stop_area:SNCF:87722025",
    "Lyon Saint-Exupéry TGV": "stop_area:SNCF:87726800",
    "Grenoble": "stop_area:SNCF:87747000",
    "Chambéry": "stop_area:SNCF:87741008",
    "Annecy": "stop_area:SNCF:87741009",
    "Albertville": "stop_area:SNCF:87741010",
    "Bourg-Saint-Maurice": "stop_area:SNCF:87741011",
    "Valence TGV": "stop_area:SNCF:87763800",
    "Valence Ville": "stop_area:SNCF:87763000",
    "Saint-Étienne Châteaucreux": "stop_area:SNCF:87726000",
    "Clermont-Ferrand": "stop_area:SNCF:87611009",
    "Marseille Saint-Charles": "stop_area:SNCF:87751008",
    "Aix-en-Provence TGV": "stop_area:SNCF:87751800",
    "Avignon TGV": "stop_area:SNCF:87758000",
    "Avignon Centre": "stop_area:SNCF:87758001",
    "Toulon": "stop_area:SNCF:87753000",
    "Les Arcs-Draguignan": "stop_area:SNCF:87753001",
    "Saint-Raphaël Valescure": "stop_area:SNCF:87753002",
    "Cannes": "stop_area:SNCF:87753003",
    "Antibes": "stop_area:SNCF:87753004",
    "Nice Ville": "stop_area:SNCF:87756056",
    "Menton": "stop_area:SNCF:87756057",
}

COMMERCIAL_MODES_TGV = {"TGV", "TGV INOUI", "INOUI", "OUIGO"}

# ─────────────────────────────────────────────
#  OUTILS
# ─────────────────────────────────────────────
def parse_dt(dt_str):
    if not dt_str: return None
    try: return datetime.strptime(dt_str, "%Y%m%dT%H%M%S")
    except: return None

def fmt_dt(dt):
    return dt.strftime("%d/%m/%Y %H:%M") if dt else "—"

def get_session():
    s = requests.Session()
    s.auth = (SNCF_API_KEY, "")
    s.headers.update({"Accept": "application/json"})
    return s

# ─────────────────────────────────────────────
#  REQUÊTE NAVITIA
# ─────────────────────────────────────────────
def fetch_departures(session, stop_area_id, gare_name, dt_from, duration_sec=3600):
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
        print(f"⚠ Erreur API pour {gare_name} : {e}")
        return []

    deps = resp.json().get("departures", [])
    trains = []

    for dep in deps:
        line = dep.get("route", {}).get("line", {})
        mode = line.get("commercial_mode", {}).get("name", "").upper()

        if not any(m in mode for m in COMMERCIAL_MODES_TGV):
            continue

        info = dep.get("display_informations", {})
        stop_dt = dep.get("stop_date_time", {})

        dep_rt = parse_dt(stop_dt.get("departure_date_time"))
        dep_base = parse_dt(stop_dt.get("base_departure_date_time"))

        trains.append({
            "train_number": info.get("trip_short_name") or info.get("headsign", "?"),
            "transport_type": mode,
            "origin": gare_name,
            "destination": info.get("direction", "Inconnue").strip(),
            "departure_time": (dep_rt or dep_base).isoformat() if (dep_rt or dep_base) else None,
            "DatetimeObj": dep_rt or dep_base
        })

    return trains

# ─────────────────────────────────────────────
#  PROGRAMME PRINCIPAL
# ─────────────────────────────────────────────
def main():
    if SNCF_API_KEY == "VOTRE_CLE_SNCF" or SUPABASE_URL == "https://votre-projet.supabase.co":
        print("⛔ Veuillez configurer vos clés API au début du script.")
        sys.exit(1)

    # Initialisation Supabase
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    session = get_session()

    jours = 30              # ← On récupère 1 mois de données
    fenetre_h = 24
    duration_sec = fenetre_h * 3600

    maintenant = datetime.now()
    print("=" * 70)
    print(f"MAJ CACHE TGV — {jours} jours à partir de {fmt_dt(maintenant)}")
    print("=" * 70)

    tous_les_trains = []

    for j in range(jours):
        dt = maintenant + timedelta(days=j)
        print(f"📅 Récupération Jour {j+1}/{jours} ({dt.strftime('%d/%m/%Y')}) ...")

        for gare_name, stop_id in GARES_TGV.items():
            trains = fetch_departures(session, stop_id, gare_name, dt, duration_sec)
            tous_les_trains.extend(trains)
            time.sleep(0.1) # Respecter les limites de l'API

    # Nettoyage et préparation des données
    df = pd.DataFrame(tous_les_trains)
    if df.empty:
        print("\n❌ Aucun train trouvé.")
        return

    # Supprimer les doublons techniques
    df = df.drop_duplicates(subset=["train_number", "origin", "departure_time"])
    
    # On ne garde que les colonnes correspondant à la table Supabase
    records = df.drop(columns=["DatetimeObj"]).to_dict('records')

    print(f"\n🚀 Envoi de {len(records)} trajets vers Supabase...")

    try:
        # 1. Optionnel : Vider l'ancien cache pour ne pas accumuler des données périmées
        # supabase.table("tgv_schedules").delete().neq("id", "00000000-0000-0000-0000-000000000000").execute()
        
        # 2. Insertion par lots (plus efficace)
        batch_size = 500
        for i in range(0, len(records), batch_size):
            batch = records[i:i+batch_size]
            supabase.table("tgv_schedules").insert(batch).execute()
            print(f"  ✅ Batch {i//batch_size + 1} envoyé ({len(batch)} records)")

        print("\n✨ MISE À JOUR RÉUSSIE ! Le cache est prêt pour l'application.")
    except Exception as e:
        print(f"\n❌ Erreur lors de l'envoi vers Supabase : {e}")

    print("=" * 70)

if __name__ == "__main__":
    main()
