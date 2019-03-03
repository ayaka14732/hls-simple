{-# LANGUAGE TypeFamilies #-}

module Foundation where

import Data.Time.Clock
import Yesod
import Yesod.Static

import HLS.PlayList (PlayList)

data App = App
  { getStatic  :: Static
  , playList   :: PlayList
  , launchTime :: UTCTime
  }

mkYesodData "App" [parseRoutesNoCheck|
/playlist.m3u8 StreamR GET
/ StaticR Static getStatic
|]

instance Yesod App
