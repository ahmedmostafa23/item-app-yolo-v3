items = []

def health_check():
    return {"result": "healthy"}

def get_items():
    return {"result": items}

def add_item(item):
    global items
    items.append(item)
    return {"result": item}

