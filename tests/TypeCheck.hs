{-# LANGUAGE OverloadedStrings #-}

module TypeCheck where

import Data.Monoid (mempty, (<>))
import Data.Text.Lazy (Text)
import Test.Tasty (TestTree)

import qualified Control.Exception
import qualified Data.Text.Lazy
import qualified Dhall.Core
import qualified Dhall.Import
import qualified Dhall.Parser
import qualified Dhall.TypeCheck
import qualified Test.Tasty
import qualified Test.Tasty.HUnit

typecheckTests :: TestTree
typecheckTests =
    Test.Tasty.testGroup "typecheck tests"
        [ Test.Tasty.testGroup "Prelude examples"
            [ should "Monoid" "./examples/Monoid/00"
            , should "Monoid" "./examples/Monoid/01"
            , should "Monoid" "./examples/Monoid/02"
            , should "Monoid" "./examples/Monoid/03"
            , should "Monoid" "./examples/Monoid/04"
            , should "Monoid" "./examples/Monoid/05"
            , should "Monoid" "./examples/Monoid/06"
            , should "Monoid" "./examples/Monoid/07"
            , should "Monoid" "./examples/Monoid/08"
            , should "Monoid" "./examples/Monoid/09"
            , should "Monoid" "./examples/Monoid/10"
            ]
        , should
            "allow type-valued fields in a record"
            "fieldsAreTypes"
        , should
            "allow type-valued alternatives in a union"
            "alternativesAreTypes"
        , should
            "allow anonymous functions in types to be judgmentally equal"
            "anonymousFunctionsInTypes"
        ]

should :: Text -> Text -> TestTree
should name basename =
    Test.Tasty.HUnit.testCase (Data.Text.Lazy.unpack name) $ do
        let actualCode   = "./tests/typecheck/" <> basename <> "A.dhall"
        let expectedCode = "./tests/typecheck/" <> basename <> "B.dhall"

        actualExpr <- case Dhall.Parser.exprFromText mempty actualCode of
            Left  err  -> Control.Exception.throwIO err
            Right expr -> return expr
        expectedExpr <- case Dhall.Parser.exprFromText mempty expectedCode of
            Left  err  -> Control.Exception.throwIO err
            Right expr -> return expr

        let annotatedExpr = Dhall.Core.Annot actualExpr expectedExpr

        resolvedExpr <- Dhall.Import.load annotatedExpr
        case Dhall.TypeCheck.typeOf resolvedExpr of
            Left  err -> Control.Exception.throwIO err
            Right _   -> return ()
