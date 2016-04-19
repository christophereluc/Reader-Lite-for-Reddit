//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Christopher Luc on 4/10/16.
//  Copyright © 2016 Christopher Luc. All rights reserved.
//

import Foundation

extension APIClient {
    
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "www.reddit.com"
        static let APIAuthHost = "oauth.reddit.com"
        static let APIPath = "/"
        static let APIReturnType = ".json"
        static let APIV1Path = "/api/v1"
        
    }
    
    struct Methods {
        static let Authorize = "/authorize"
        static let Revoke = "/revoke_token"
        static let AccessToken = "/access_token"
        static let Messages = "/message/inbox"
    }
    
    struct RedditParameterKeys {
        static let Count = "count"
        static let Before = "before"
        static let After = "after"
        static let ClientId = "client_id"
        static let ResponseType = "response_type"
        static let State = "state"
        static let Redirect = "redirect_uri"
        static let Duration = "duration"
        static let Scope = "scope"
        static let GrantType = "grant_type"
        static let Code = "code"
        static let Token = "token"
    }
    
    struct RedditParameterValues {
        static let CountValue = "10"
        static let ClientValue = "sg_mBS9Ez4CRjg"
        static let ResponseValue = "code"
        static let StateValue = "testing"
        static let RedirectValue = "readerlite://response"
        static let DurationValue = "permanent"
        static let ScopeValue = "identity edit flair history modconfig modflair modlog modposts modwiki mysubreddits privatemessages read report save submit subscribe vote wikiedit wikiread"
        static let GrantTypeValue = "authorization_code"
    }
    
    struct RedditHeaderKeys {
        static let User = "user"
        static let ClientSecret = "client_secret"
        static let Authorization = "Authorization"
    }
    
    struct RedditHeaderValues {
        static let UserValue = "sg_mBS9Ez4CRjg"
        static let ClientSecretValue = ""
        static let AuthorizationValue = "bearer "
    }
    
    struct RedditResponseKeys {
        static let Data = "data"
        static let Before = "before"
        static let After = "after"
        static let Children = "children"
        static let Author = "author"
        static let Permalink = "permalink"
        static let Thumbnail = "thumbnail"
        static let Title = "title"
        static let Url = "url"
        static let Id = "id"
        static let Domain = "domain"
        static let Subreddit = "subreddit"
        static let AccessToken = "access_token"
        static let Body = "body"
        static let CreatedUtc = "created_utc"
    }
    
    //Special oAuth url for requesting a permanent token from reddit
    var oAuthUrl : String {
        let url = Constants.APIScheme + "://" + Constants.APIHost + Constants.APIV1Path +  Methods.Authorize + ".compact" + "?" +
            RedditParameterKeys.ClientId + "=" + RedditParameterValues.ClientValue + "&" +
            RedditParameterKeys.ResponseType + "=" + RedditParameterValues.ResponseValue + "&" +
            RedditParameterKeys.State + "=" + RedditParameterValues.StateValue + "&" +
            RedditParameterKeys.Redirect + "=" + RedditParameterValues.RedirectValue + "&" +
            RedditParameterKeys.Duration + "=" + RedditParameterValues.DurationValue + "&" +
            RedditParameterKeys.Scope + "=" + RedditParameterValues.ScopeValue
        
        return url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
}