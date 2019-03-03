{-# LANGUAGE NamedFieldPuns #-}

module Handler.Stream (getStreamR) where

import Data.Time.Clock
import Yesod

import Foundation
import HLS.GenList (toLivePlayListString)

getStreamR :: Handler TypedContent
getStreamR = do
  App{playList,launchTime} <- getYesod
  currTime <- liftIO getCurrentTime
  let timestamp = realToFrac (currTime `diffUTCTime` launchTime)
  pure $ TypedContent "application/vnd.apple.mpegurl" $ toContent $ toLivePlayListString playList timestamp
