items = []

def health_check(request):
    
    return {"result": request.get_json(), "health": "healthy"}

def get_items():
    return {"result": items}

def add_item(item):
    global items
    items.append(item)
    return {"result": item}

