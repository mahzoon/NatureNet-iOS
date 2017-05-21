//
//  Constants.swift
//  NatureNet
//
//  Created by Mahzoon, Mohammad Javad on 5/16/17.
//  Copyright © 2017 NatureNet. All rights reserved.
//

import Foundation
import UIKit

//
// Colors
//

// the green color
let APP_COLOR_LIGHT = UIColor(red: 31.0/255.0, green: 205.0/255.0, blue: 108.0/255.0, alpha: 1.0)
// the navy color
let APP_COLOR_DARK = UIColor(red: 53.0/255.0, green: 74.0/255.0, blue: 95.0/255.0, alpha: 1.0)
// the shadow color
let APP_COLOR_SHADOW = UIColor(red: 157.0/255.0, green: 157.0/255.0, blue: 157.0/255.0, alpha: 1.0)


//
// Icons names
//
let JOIN_PROFILE_IMAGE = "join screen - user"
let ADD_OBSV_IMAGE = "icon - observation default"
let HIDE_KEYBOARD = "icon - down"
let SHOW_KEYBOARD = "icon - up"
// Icons used in code
let HIDE_KEYBOARD_IMAGE = UIImage(named: "icon - down")
let SHOW_KEYBOARD_IMAGE = UIImage(named: "icon - up")

//
// Sizes
//
let COMMENT_CELL_ESTIMATED_HEIGHT = 25.0
let RECENT_OBSV_ESTIMATED_HEIGHT = 250.0
let DESIGN_IDEA_CELL_ITEM_HEIGHT = 150.0
let PROJECT_CELL_ITEM_HEIGHT = 50.0
let GALLERY_CELL_ITEM_HEIGHT = 300.0
let COMMUNITY_CELL_ITEM_HEIGHT = 50.0
let COMMENT_TEXTBOX_MAX_HEIGHT = 150



//
// Texts
//
let COMMENT_TEXTBOX_PLACEHOLDER = "Comment"

//
// Messages
//

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


