import requests

def get_wikidata_entry_by_id(wikidata_id):
    base_url = "https://www.wikidata.org/w/api.php"
    params = {
        "action": "wbgetentities",
        "format": "json",
        "ids": wikidata_id
    }

    response = requests.get(base_url, params=params)
    data = response.json()

    if "entities" in data:
        entity = data["entities"].get(wikidata_id)
        return entity
    else:
        return None

# Example usage
wikidata_id = "Q61"  # Replace with the desired Wikidata ID
entity_data = get_wikidata_entry_by_id(wikidata_id)

if entity_data:
    print("Entity ID:", entity_data["id"])
    print("Entity Label:", entity_data["labels"]["en"]["value"])
    print("Description:", entity_data["descriptions"]["en"]["value"])
    # You can access other properties as needed
    print("\nEnglish Properties:")
    for prop_id, prop_data in entity_data.get("claims", {}).items():
        if "datavalue" in prop_data["mainsnak"] and "value" in prop_data["mainsnak"]["datavalue"]:
            if prop_data["mainsnak"]["datavalue"]["value"].get("language") == "en":
                print(prop_id, "-", prop_data["mainsnak"]["datavalue"]["value"]["text"])
else:
    print("Entity not found.")
