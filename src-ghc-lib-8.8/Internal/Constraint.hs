module Internal.Constraint (newGiven, flatToCt) where

import GhcApi.GhcPlugins
import GhcApi.Constraint
  (Ct(..), CtEvidence(..), CtLoc, ctLoc, ctEvId, mkNonCanonical)

import Panic (panicDoc)
import TcType (TcType)
import TcEvidence (EvTerm(..))
import TcPluginM (TcPluginM)
import qualified TcPluginM (newGiven)

-- | Create a new [G]iven constraint, with the supplied evidence. This must not
-- be invoked from 'tcPluginInit' or 'tcPluginStop', or it will panic.
newGiven :: CtLoc -> PredType -> EvTerm -> TcPluginM CtEvidence
newGiven loc pty (EvExpr ev) = TcPluginM.newGiven loc pty ev
newGiven _ _  ev = panicDoc "newGiven: not an EvExpr: " (ppr ev)

flatToCt :: [((TcTyVar,TcType),Ct)] -> Maybe Ct
flatToCt [((_,lhs),ct),((_,rhs),_)]
  = Just
  $ mkNonCanonical
  $ CtGiven (mkPrimEqPred lhs rhs)
            (ctEvId ct)
            (ctLoc ct)

flatToCt _ = Nothing
