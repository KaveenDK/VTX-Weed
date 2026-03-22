-- Add these items to your ox_inventory/data/items.lua

    ['weed_leaf'] = {
        label = 'Weed Leaf',
        weight = 10,
        stack = true,
        close = true,
        description = 'Freshly harvested weed leaves, ready for processing.',
        client = {
            image = 'weed_leaf.png',
        }
    },
    
    ['weed_package'] = {
        label = 'Weed Package',
        weight = 200,
        stack = true,
        close = true,
        description = 'A fully processed and packed block of weed.',
        client = {
            image = 'weed_package.png',
        }
    },