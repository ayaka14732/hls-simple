{-# OPTIONS_GHC -Wno-orphans #-}

import Data.Time.Clock (getCurrentTime)
import Network.Wai.Handler.Warp (run)
import Yesod
import Yesod.Static (static)

import Foundation
import Handler.Stream (getStreamR)
import HLS.ReadList (readAndMergePlayListFiles)

mkYesodDispatch "App" resourcesApp

main :: IO ()
main = do
  s <- static "static"
  p <- readAndMergePlayListFiles "hls"
  t <- getCurrentTime
  wApp <- toWaiApp App
    { getStatic  = s
    , playList   = p
    , launchTime = t
    }
  run 3000 wApp
