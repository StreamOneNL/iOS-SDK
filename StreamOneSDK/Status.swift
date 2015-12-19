//
//  Status.swift
//  StreamOneSDK
//
//  Created by Nicky Gerritsen on 14-09-15.
//  Copyright © 2015 StreamOne. All rights reserved.
//

import Foundation
import Argo

/**
    Enum containing constants for all errors codes the API can report 
 */
public enum Status: Int {
    /**
        An unknown status
     */
    case Unknown = -1

    /**
        Everything went fine
    */
    case OK = 0

    /**
        Something went wrong internally
    */
    case InternalError = 1

    /**
        Provided timestamp is outside of the allowed range
    */
    case TimestampOutOfRange = 2

    /**
        Actor authentication failed
    */
    case AuthenticationFailed = 3

    /**
        Access to requested command/action denied for actor
    */
    case AccessDenied = 4

    /**
        Supplied command or action was not found
    */
    case InvalidAction = 5

    /**
        Input for action was not properly specified
    */
    case InputError = 6

    /**
        One of the supplied parameters was not recognized
    */
    case UnknownParameter = 7

    /**
        This request has been rate limited (due to invalid authentication)
    */
    case RateLimited = 8

    /**
        Given timezone is not valid
    */
    case InvalidTimezone = 9

    /**
        The API is in read-only mode
    */
    case ApiInReadonlyMode = 10

    /**
        Given action is not marked as read-only or read-write (logic error)
    */
    case InvalidActionType = 90

    /**
        The requested job was not found
    */
    case JobNotFound = 100

    /**
        The requested worker was not found
    */
    case WorkerNotFound = 101

    /**
        The given worker does not match the requirements
    */
    case WorkerInvalid = 102

    /**
        The job is in an invalid state for this operation
    */
    case JobInvalidStatus = 103

    /**
        The given worker does not run on the correct server
    */
    case WorkerWrongServer = 104

    /**
        The requested live task was not found
    */
    case LiveTaskNotFound = 105

    /**
        The live task is in an invalid state for this operation
    */
    case LiveTaskInvalidStatus = 106

    /**
        The worker already has this job / live task type
    */
    case WorkerAlreadyHasType = 107

    /**
        The worker does not have this job / live task type
    */
    case WorkerDoesNotHaveType = 108

    /**
        The server already has a worker
    */
    case ServerAlreadyHasWorker = 109

    /**
        The requested file was not found
    */
    case FileNotFound = 110

    /**
        The requested file has a different extension
    */
    case FileWrongExtension = 111

    /**
        The requested file has a different size
    */
    case FileWrongSize = 112

    /**
        The requested file location was not found
    */
    case FileLocationNotFound = 113

    /**
        The requested file server was not found
    */
    case FileServerNotFound = 114

    /**
        The requested mount was not found
    */
    case FileMountNotFound = 115

    /**
        The requested mount does not reside on the requested server
    */
    case FileMountNotOnServer = 116

    /**
        The location to be added already exists
    */
    case FileLocationExists = 117

    /**
        No suitable mount found
    */
    case FileNoSuitableMount = 118

    /**
        Unable to copy file
    */
    case FileCopyFailed = 119

    /**
        The requested item could not be found
    */
    case ItemNotFound = 120

    /**
        The requested item does not belong to the active account
    */
    case ItemInvalidAccount = 121

    /**
        The requsted item file was not found
    */
    case ItemFileNotFound = 122

    /**
        The requested item file does not belong to the requested item
    */
    case ItemFileWrongItem = 123

    /**
        The requested item has no files
    */
    case ItemNoFiles = 124

    /**
        The category already contains this item
    */
    case ItemAlreadyInCategory = 125

    /**
        The category does not contain this item
    */
    case ItemNotInCategory = 126

    /**
        The requested server could not be found
    */
    case ServerNotFound = 130

    /**
        The requested server does not have a required role
    */
    case ServerMissingRole = 131

    /**
        This actor does not have permission to add this role to this server
    */
    case ServerNotPermitted = 132

    /**
        This server already has this role
    */
    case ServerRoleAlreadyAssigned = 133

    /**
        The requested server role was not found
    */
    case ServerRoleNotFound = 134

    /**
        This server does not have this role
    */
    case ServerRoleNotAssigned = 135

    /**
        The requested file category was not found
    */
    case FileCategoryNotFound = 140

    /**
        The requested file is empty (has no locations)
    */
    case FileEmpty = 141

    /**
        The requested file is not empty (has locations)
    */
    case FileNotEmpty = 142

    /**
        The requested file has a different MD5 hash
    */
    case FileWrongMd5 = 143

    /**
        The requested external mount does not exist
    */
    case FileExternalMountNotFound = 144

    /**
        The requested file was not found on the external mount
    */
    case FileNotFoundOnExternalMount = 145

    /**
        The requested event was not found
    */
    case EventNotFound = 150

    /**
        The requested event hook was not found
    */
    case EventHookNotFound = 160

    /**
        The given target is invalid
    */
    case EventHookInvalidTarget = 161

    /**
        The requested event hook type was not found
    */
    case EventHookTypeNotFound = 170

    /**
        The event hook type is invalid for this operation
    */
    case EventHookTypeInvalid = 171

    /**
        The requested event hook log entry was not found
    */
    case EventHookLogNotFound = 180

    /**
        The requested event hook log entry is of the wrong type
    */
    case EventHookLogWrongType = 181

    /**
        The requested event hook log entry could not be handled
    */
    case EventHookLogCannotHandle = 182

    /**
        The requested upload token was not found
    */
    case UploadTokenNotFound = 190

    /**
        The requested transcode profile was not found
    */
    case TranscodeProfileNotFound = 200

    /**
        The transcode source does not have a video track
    */
    case TranscodeSourceHasNoVideo = 201

    /**
        The transcode source does not have an audio track
    */
    case TranscodeSourceHasNoAudio = 202

    /**
        The requested category was not found
    */
    case CategoryNotFound = 210

    /**
        The given parent has the provided category as parent, would create a loop
    */
    case CategoryParentWrong = 211

    /**
        The category still has items linked to it
    */
    case CategoryHasLinkedItems = 212

    /**
        The requested playlist was not found
    */
    case PlaylistNotFound = 220

    /**
        The requested playlist entry was not found
    */
    case PlaylistEntryNotFound = 230

    /**
        The requested livestream was not found
    */
    case LivestreamNotFound = 240

    /**
        The livestream is already started
    */
    case LivestreamAlreadyStarted = 241

    /**
        The livestream is not yet started
    */
    case LivestreamNotYetStarted = 242

    /**
        The requested livestream type was not found
    */
    case LivestreamTypeNotFound = 243

    /**
        The requested customer was not found
    */
    case CustomerNotFound = 250

    /**
        The requested application was not found
    */
    case ApplicationNotFound = 260

    /**
        The requested role can not be added or removed by the current actor
    */
    case ApplicationNotPermitted = 261

    /**
        The requested role is already assigned to this application
    */
    case ApplicationRoleAlreadyAssigned = 262

    /**
        The requested role is not yet assigned to this application
    */
    case ApplicationRoleNotAssigned = 263

    /**
        The requested role was not found
    */
    case RoleNotFound = 270

    /**
        The requested token was not found
    */
    case TokenNotFound = 271

    /**
        The role already has this token
    */
    case RoleAlreadyHasToken = 272

    /**
        The requested role does not have this token
    */
    case RoleDoesNotHaveToken = 273

    /**
        The requested token can not be added or removed by the current actor
    */
    case RoleNotPermitted = 274

    /**
        This role is still used for an application or user
    */
    case RoleStillUsed = 275

    /**
        Creating the session required an API version 2 hash, but it was not supplied
    */
    case SessionNeedsV2Hash = 280

    /**
        The session could not be created due to some reason
    */
    case SessionInvalid = 281

    /**
        The requested session was not found
    */
    case SessionNotFound = 282

    /**
        The requested account was not found
    */
    case AccountNotFound = 290

    /**
        The account already has this profile group
    */
    case AccountAlreadyHasProfileGroup = 291

    /**
        The account does not have this profile group
    */
    case AccountDoesNotHaveProfileGroup = 292

    /**
        The requested profile group was not found
    */
    case ProfileGroupNotFound = 300

    /**
        The requestes user was not found
    */
    case UserNotFound = 310

    /**
        The requested role can not be added or removed by the current actor
    */
    case UserNotPermitted = 311

    /**
        The requested role is already assigned to this user
    */
    case UserRoleAlreadyAssigned = 312

    /**
        The requested role is not yet assigned to this user
    */
    case UserRoleNotAssigned = 313

    /**
        The user password change request is invalid
    */
    case UserPasswordChangeInvalid = 314

    /**
        The user password reset request was not found or is expired
    */
    case UserPasswordResetNotFoundOrExpired = 315

    /**
        The username already exists
    */
    case UserUsernameAlreadyExists = 316

    /**
        The requested schedule was not found
    */
    case ScheduleNotFound = 320

    /**
        The schedule already has this category
    */
    case ScheduleAlreadyHasCategry = 325

    /**
        The schedule does not have this category
    */
    case ScheduleDoesNotHaveCategry = 326

    /**
        The requested player was not found
    */
    case PlayerNotFound = 330

    /**
        The player already has this origin
    */
    case PlayerAlreadyHasOrigin = 331

    /**
        The player does not have this origin
    */
    case PlayerDoesNotHaveOrigin = 332

    /**
        The requested origin was not found
    */
    case OriginNotFound = 340

    /**
        The requested platform support task was not found
    */
    case PlatformSupportTaskNotFound = 350

    /**
        The requested job type was not found
    */
    case JobTypeNotFound = 360

    /**
        The requested live task type was not found
    */
    case LiveTaskTypeNotFound = 361

    /**
        The requested profile was not found
    */
    case ProfileNotFound = 370

    /**
        The requested item file format was not found
    */
    case ItemFileFormatNotFound = 371

    /**
        The requested item type was not found
    */
    case ItemTypeNotFound = 372

    /**
        The requested audio codec was not found
    */
    case AudioCodecNotFound = 373

    /**
        The requested video codec was not found
    */
    case VideoCodecNotFound = 374

    /**
        The requested video codec profile was not found
    */
    case VideoCodecProfileNotFound = 375

    /**
        The requested profile belongs to a specific account, but the profile group is system-wide
    */
    case ProfileIsOfSpecificAccount = 376

    /**
        The profile group already has this profile
    */
    case ProfileGroupAlreadyHasProfile = 377

    /**
        The profile group does not have this profile
    */
    case ProfileGroupDoesNotHaveProfile = 378

    /**
        The profile group has an height that is not supported for interlaced output
    */
    case ProfileInvalidHeightForInterlaced = 379

    /**
        The requested security profile was not found
    */
    case SecurityProfileNotFound = 380

    /**
        The security rule is not valid
    */
    case SecurityRuleNotValid = 381

    /**
        The requested security rule was not found
    */
    case SecurityRuleNotFound = 382

    /**
        An invalid time selection range was supplied (spans zero or negative time)
    */
    case StatsRangeInvalid = 390

    /**
        An invalid resoltuion was supplied
    */
    case StatsResolutionInvalid = 391

    /**
        An invalid scope was supplied
    */
    case StatsScopeInvalid = 392

    /**
        The requested client group was not found
    */
    case ClientGroupNotFound = 400

    /**
        The requested client was not found
    */
    case ClientNotFound = 401

    /**
        The client group already contains this client
    */
    case ClientGroupAlreadyHasClient = 402

    /**
        The client group does not contain this client
    */
    case ClientGroupDoesNotHaveClient = 403

    /**
        The requested record task could not be found
    */
    case RecordTaskNotFound = 410

    /**
        The record task has an invalid status
    */
    case RecordTaskInvalidStatus = 411

    /**
        The FTP user with the given username already exists
    */
    case FtpUserAlreadyExists = 420

    /**
        The FTP user could not be found
    */
    case FtpUserNotFound = 421
}

extension Status : Decodable {
    /**
        Decode a JSON object into a status

        - Parameter json: The JSON to decode
        - Returns: The decoded status
    */
    public static func decode(json: JSON) -> Decoded<Status> {
        switch json {
        case let .Number(n):
            return .fromOptional(Status(rawValue: n.integerValue))
        default:
            return Decoded<Status>.typeMismatch("Integer", actual: json)
        }
    }
}