{-# LANGUAGE OverloadedStrings #-}

module Main where

import Prelude.Compat

import           System.Environment (getArgs)
import qualified System.IO as IO
import           System.IO (IO)
import qualified Options.Applicative as Opts
import qualified Text.PrettyPrint.ANSI.Leijen as Doc
import qualified Build as Build
import           Version (versionString)

main :: IO ()
main = do
    IO.hSetEncoding IO.stdout IO.utf8
    IO.hSetEncoding IO.stderr IO.utf8

    cmd <- Opts.handleParseResult . execParserPure opts =<< getArgs
    cmd
  where
    opts        = Opts.info (versionInfo <*> optsParser) infoModList
    infoModList = Opts.fullDesc <> headerInfo <> footerInfo
    headerInfo  = Opts.progDesc "PureScript erlang backend (purerl)"
    footerInfo  = Opts.footerDoc (Just footer)

    footer =
      mconcat
        [ para $
            "For help using each individual command, run `purerl COMMAND --help`. " ++
            "For example, `purerl compile --help` displays options specific to the `compile` command."
        , Doc.hardline
        , Doc.hardline
        , Doc.text $ "purerl " ++ versionString
        ]

    para :: String -> Doc.Doc
    para = foldr (Doc.</>) Doc.empty . map Doc.text . words

    execParserPure :: Opts.ParserInfo a -> [String] -> Opts.ParserResult a
    execParserPure pinfo args = Opts.execParserPure Opts.defaultPrefs pinfo args

    versionInfo :: Opts.Parser (a -> a)
    versionInfo = Opts.abortOption (Opts.InfoMsg versionString) $
      Opts.long "version" <> Opts.help "Show the version number" <> Opts.hidden

    optsParser :: Opts.Parser (IO ())
    optsParser = Build.parser