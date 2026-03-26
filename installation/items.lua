-- Add these items to your ox_inventory/data/items.lua

    ['weed_leaf'] = {
        label = 'Weed Leaf',
        weight = 10,
        stack = true,
        close = true,
        description = 'Freshly harvested weed leaves, ready to be crushed.',
        client = {
            image = 'weed_leaf.png',
        }
    },

    ['crushed_weed'] = {
        label = 'Crushed Weed',
        weight = 10,
        stack = true,
        close = true,
        description = 'Finely crushed weed, ready to be packaged.',
        client = {
            image = 'crushed_weed.png',
        }
    },

    ['weed_baggy_empty'] = {
        label = 'Empty Weed Baggy',
        weight = 1,
        stack = true,
        close = true,
        description = 'Small empty baggies used for packaging goods.',
        client = {
            image = 'weed_baggy_empty.png',
        }
    },
    
    ['weed_package'] = {
        label = 'Weed Package',
        weight = 200,
        stack = true,
        close = true,
        description = 'A fully processed and packed bag of weed.',
        client = {
            image = 'weed_package.png',
        }
    },