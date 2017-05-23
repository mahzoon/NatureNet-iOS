//
//  Constants.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//
// Colors
//

// the green color
let APP_COLOR_LIGHT = UIColor(red: 31.0/255.0, green: 205.0/255.0, blue: 108.0/255.0, alpha: 1.0)
// the navy color
let APP_COLOR_DARK = UIColor(red: 53.0/255.0, green: 74.0/255.0, blue: 95.0/255.0, alpha: 1.0)
// the shadow color
let APP_COLOR_SHADOW = UIColor(red: 157.0/255.0, green: 157.0/255.0, blue: 157.0/255.0, alpha: 1.0)
// pin colors
let PIN_COLORS: [String: UIColor] = ["aces": UIColor.blue, "rcnc": UIColor.green, "aws": UIColor.red, "zz_elsewhere": UIColor.cyan]
// default pin color
let DEFAULT_PIN_COLOR = UIColor.darkGray

//
// Icons names
//
let JOIN_PROFILE_IMAGE = "join screen - user"
let ADD_OBSV_IMAGE = "icon - observation default"
let PROJECT_DEFAULT_ICON = "icon - project - default"
// Icons used in code
let ICON_PROFILE_ONLINE = UIImage(named: "icon - profile - online")
let ICON_PROFILE_OFFLINE = UIImage(named: "icon - profile - offline")


//
// Sizes
//
let COMMENT_CELL_ESTIMATED_HEIGHT = 25.0
let RECENT_OBSV_ESTIMATED_HEIGHT = 250.0
let DESIGN_IDEA_CELL_ITEM_HEIGHT = 180.0
let PROJECT_CELL_ITEM_HEIGHT = 50.0
let GALLERY_CELL_ITEM_HEIGHT = 300.0
let COMMUNITY_CELL_ITEM_HEIGHT = 50.0
let SHOW_MORE_CELL_HEIGHT = 50.0
let COMMENT_TEXTBOX_MAX_HEIGHT = 150
let MAP_CENTER_REGION_RADIUS: CLLocationDistance = 10000 // in meters, which is 10Km
//
let COMMUNITY_LIST_INIT_COUNT = 15
let COMMUNITY_LIST_LOAD_MORE_COUNT = 15
//
let PROJECTS_LIST_INIT_COUNT = 3
let PROJECTS_LIST_LOAD_MORE_COUNT = 3
//
let DESIGN_IDEA_LIST_INIT_COUNT = 10
let DESIGN_IDEA_LIST_LOAD_MORE_COUNT = 10
//
let GALLERY_LIST_INIT_COUNT = 5
let GALLERY_LIST_LOAD_MORE_COUNT = 5
//
let DETAILED_OBSV_LIST_INIT_COUNT = 5
let DETAILED_OBSV_LIST_LOAD_MORE_COUNT = 5
//
let COMMENT_LIST_INIT_COUNT = 5
let COMMENT_LIST_LOAD_MORE_COUNT = 5


//
// Texts
//
let COMMENT_TEXTBOX_PLACEHOLDER = "Comment"
let PICKER_NO_SELECTION = "Select one"
let LISTS_SHOW_MORE_TEXT = "Show more..."
let NO_COMMENTS_TEXT = "No comments."

//
// Messages
//

// Sign in Screen
let SIGN_IN_ERRORS_TITLE = "Sign in"
let SIGN_IN_ERRORS_BUTTON_TEXT = "OK"
let SIGN_IN_NO_EMAIL_PROVIDED = "Please enter your email."
let SIGN_IN_NO_PASSWORD_PROVIDED = "Please enter your password."

// Profile Screen
let PROFILE_ERRORS_TITLE = "Sign Out"
let PROFILE_ERRORS_BUTTON_TEXT = "Ok"


// Join Screen
let JOIN_PROFILE_IMAGE_OPTIONS_TITLE = "Choose an Option: "
let JOIN_PROFILE_IMAGE_OPTIONS_MSG: String? = nil
let JOIN_PROFILE_IMAGE_OPTIONS_CANCEL = "Cancel"
let JOIN_PROFILE_IMAGE_OPTIONS_PICK_EXISTING = "Pick an existing from photo library"
let JOIN_PROFILE_IMAGE_OPTIONS_TAKE_NEW = "Take a new one"
let JOIN_PROFILE_IMAGE_OPTIONS_REMOVE_CURRENT = "Remove current photo"
let JOIN_PROFILE_IMAGE_OPTIONS_ERR_LIB_TITLE = "Error accessing photo library"
let JOIN_PROFILE_IMAGE_OPTIONS_ERR_LIB_MSG = "Can not have access to your photo library. Maybe the privacy settings will not let the app use your photo library."
let JOIN_PROFILE_IMAGE_OPTIONS_ERR_LIB_BTN_TXT = "OK"
let JOIN_PROFILE_IMAGE_OPTIONS_ERR_CAM_TITLE = "Error accessing camera"
let JOIN_PROFILE_IMAGE_OPTIONS_ERR_CAM_MSG = "Can not have access to your camera. Maybe the privacy settings will not let the app use your camera."
let JOIN_PROFILE_IMAGE_OPTIONS_ERR_CAM_BTN_TXT = "OK"

// Add Observation Screen
let ADD_OBSV_IMAGE_OPTIONS_TITLE = "Choose an Option: "
let ADD_OBSV_IMAGE_OPTIONS_MSG: String? = nil
let ADD_OBSV_IMAGE_OPTIONS_CANCEL = "Cancel"
let ADD_OBSV_IMAGE_OPTIONS_PICK_EXISTING = "Pick an existing from photo library"
let ADD_OBSV_IMAGE_OPTIONS_TAKE_NEW = "Take a new one"
let ADD_OBSV_IMAGE_OPTIONS_REMOVE_CURRENT = "Remove current photo"
let ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_TITLE = "Error accessing photo library"
let ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_MSG = "Can not have access to your photo library. Maybe the privacy settings will not let the app use your photo library."
let ADD_OBSV_IMAGE_OPTIONS_ERR_LIB_BTN_TXT = "OK"
let ADD_OBSV_IMAGE_OPTIONS_ERR_CAM_TITLE = "Error accessing camera"
let ADD_OBSV_IMAGE_OPTIONS_ERR_CAM_MSG = "Can not have access to your camera. Maybe the privacy settings will not let the app use your camera."
let ADD_OBSV_IMAGE_OPTIONS_ERR_CAM_BTN_TXT = "OK"

// Observation Detail Screen
let SAVE_OBSV_ALERT_TITLE:String = "How do you want to save this observation?"
let SAVE_OBSV_ALERT_MESSAGE: String? = nil
let SAVE_OBSV_ALERT_OPTION_SAVE_PHOTO = "Save the image to my photo library"
let SAVE_OBSV_ALERT_OPTION_SHARE = "Share the content in another app"
let SAVE_OBSV_ALERT_OPTION_CANCEL = "Cancel"
let SAVE_OBSV_ERROR_MESSAGE = "Could not save the observation: "
let SAVE_OBSV_ERROR_BUTTON_TEXT = "OK"
let SAVE_OBSV_SUCCESS_TITLE = "Saved!"
let SAVE_OBSV_SUCCESS_MESSAGE = "The observation has been saved successfuly."
let SAVE_OBSV_SUCCESS_BUTTON_TEXT = "OK"


//
// Segue names
//
let SEGUE_SIGNIN = "SignIn"
let SEGUE_EXPLORE = "Explore"
let SEGUE_PROFILE = "Profile"
let SEGUE_DETAILS = "Details"

//
// Database reference names
//
let DB_SITES_PATH = "sites"
let DB_PROJECTS_PATH = "activities"
let DB_USERS_PATH = "users"
let DB_OBSERVATIONS_PATH = "observations"
let DB_DESIGNIDEAS_PATH = "ideas"
let DB_COMMENTS_PATH = "comments"

