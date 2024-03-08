//
//  ProductModel.swift
//  DIPLOMA SWIFTUI
//
//  Created by Almat Kairatov on 21.02.2024.
//

import Foundation

struct BarcodeProduct: Codable {
    
    var code: String = ""
    var product: Product? = Product()
    var status: Int = -1
    var statusVerbose: String = ""

    enum CodingKeys: String, CodingKey {
        case code, product, status
        case statusVerbose = "status_verbose"
    }
}

// MARK: - Product
struct Product: Codable {
    var id: String = ""
    var additivesTags: [String]? = []
    var allergensTags: [String]? = []
    var brands: String? = ""
    var imageURL: String? = ""
    var imageNutritionThumbUrl: String? = ""
    var imageIngredientsUrl: String? = ""
    var ingredients: [Ingredient?]? = nil
    var ingredientsHierarchy: [String]? = []
    var productName: String? = ""
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case additivesTags = "additives_tags"
        case allergensTags = "allergens_tags"
        case brands
        case imageURL = "image_url"
        case imageNutritionThumbUrl = "image_nutrition_thumb_url"
        case imageIngredientsUrl = "image_ingredients_url"
        case ingredients
        case ingredientsHierarchy = "ingredients_hierarchy"
        case productName = "product_name"
    }
}

// MARK: - Ingredient
struct Ingredient: Codable, Identifiable {
    var ciqualFoodCode: String? = ""
    var id = UUID()
    var idProduct: String = ""
    var percent: Int? = -1
    var percentEstimate = 0.0
    var percentMax = 0.0
    var percentMin: Double? = 0.0
    var rank: Int? = -1
    var text: String = ""
    var vegan = FromPalmOil(rawValue: "maybe")
    var vegetarian: FromPalmOil? = FromPalmOil(rawValue: "maybe")
    var ciqualProxyFoodCode: String? = ""
    var hasSubIngredients = FromPalmOil(rawValue: "maybe")
    var fromPalmOil: FromPalmOil? = FromPalmOil(rawValue: "maybe")

    enum CodingKeys: String, CodingKey {
        case ciqualFoodCode = "ciqual_food_code"
        case idProduct = "id"
        case percent
        case percentEstimate = "percent_estimate"
        case percentMax = "percent_max"
        case percentMin = "percent_min"
        case rank, text, vegan, vegetarian
        case ciqualProxyFoodCode = "ciqual_proxy_food_code"
        case hasSubIngredients = "has_sub_ingredients"
        case fromPalmOil = "from_palm_oil"
    }
}

enum FromPalmOil: String, Codable {
    case maybe = "maybe"
    case no = "no"
    case yes = "yes"
}

