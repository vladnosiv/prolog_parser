module Parser where

import Text.ParserCombinators.Parsec

data Atom = AtomBegin    AbstractData Atom
          | AtomContinue Atom Atom
          | AtomInterior AbstractData
          | AtomEnd      Atom
          deriving Eq

instance Show Atom where
    show (AtomBegin h t)    = "(Atom " ++ show h ++ " " ++ show t ++ ")"
    show (AtomContinue h t) = show h ++ " " ++ show t
    show (AtomEnd t)        = show t
    show (AtomInterior t)   = show t


data AbstractData = Ident       String
                  | Var         String
                  | AtomTrivial AbstractData
                  | AtomComplex Atom
                  deriving Eq

instance Show AbstractData where
    show (Ident str)        = str
    show (Var str)          = "(Var " ++ str ++ ")"
    show (AtomTrivial ab)   = show ab
    show (AtomComplex atom) = show atom


data Nonterminal = Module          AbstractData
                 | TypeTrivial     AbstractData
                 | Type            Nonterminal Nonterminal
                 | Typedef         AbstractData Nonterminal
                 | Relation        AbstractData Expr
                 | TrivialRelation AbstractData
                 | RelationBody    Expr
                 deriving Eq

instance Show Nonterminal where
    show (TypeTrivial str)     = "(" ++ show str ++ ")"
    show (Module (Ident a))    = "Module " ++ a ++ ""
    show (Type a b)            = "(Type " ++ show a ++ " " ++ show b ++  ")" 
    show (Typedef (Ident a) b) = "Typedef (Typename " ++ a ++ ") " ++ show b
    show (Relation head body)  = "Relation " ++ show head ++ " " ++ show body
    show (TrivialRelation d)   = "Relation (" ++ show d ++ ")"
    show (RelationBody b)      = show b


data Expr = Disj Expr Expr
          | Conj Expr Expr
          | AbstractExpr AbstractData
          deriving Eq

instance Show Expr where
    show (Disj l r)       = "Disjunction (" ++ show l ++ ") (" ++ show r ++ ")"
    show (Conj l r)       = "Conjunction (" ++ show l ++ ") (" ++ show r ++ ")"
    show (AbstractExpr e) = show e

data Prolog = Program Nonterminal [Nonterminal] [Nonterminal]

instance Show Prolog where
    show (Program modl typedefs rels) =
        show modl ++ "\n" ++ (foldl (++) "" $ map (\x -> show x ++ "\n") typedefs)
                          ++ (foldl (++) "" $ map (\x -> show x ++ "\n") rels)

runAnyParser :: Show a => Parser a -> String -> Either ParseError a
runAnyParser parser =
  parse (do r <- parser; eof; return r) ""


-- Common Part

parseList :: Parser a -> Parser b -> Parser [a]
parseList elem sep =
    try (do
        h <- elem
        t <- many (sep >> elem)
        return (h:t)
    )


parseAbstractData :: Parser AbstractData
parseAbstractData =
    try (do
        atom <- spaces >> parseAtom
        return (AtomComplex atom)
    )
    <|>
    try (do
        atom <- spaces >> parseAtomList
        return (AtomComplex atom)
    )
    <|>
    try (do
        id <- spaces >> parseIdent
        return id
    )
    <|>
    try (do
        vr <- spaces >> parseVar
        return vr
    )


parseAtom :: Parser Atom
parseAtom = parseAtomBegin

parseAtomBegin :: Parser Atom
parseAtomBegin =
    try (do
       _  <- spaces >> char '('
       at <- spaces >> parseAtomBegin
       _  <- spaces >> char ')'
       return at 
    )
    <|>
    try (do
        h <- spaces >> parseIdent
        t <- spaces >> parseAtomContinue
        return (AtomBegin h t)
    ) 
    <|>
    try (do
        h <- spaces >> parseIdent
        t <- spaces >> parseAtomEnd
        return (AtomBegin h t)
    )


parseAtomContinue :: Parser Atom
parseAtomContinue =
    try (do
        a <- spaces >> parseAtomInterior
        t <- spaces >> parseAtomContinue
        return (AtomContinue a t)
    )
    <|>
    try (do
        prv <- spaces >> parseAtomInterior
        lst <- spaces >> parseAtomEnd
        return (AtomContinue prv lst)
    )

parseAtomInterior :: Parser Atom
parseAtomInterior =
    try (do
        _ <- spaces >> char '('
        a <- spaces >> parseAtomInterior
        _ <- spaces >> char ')'
        return a
    )
    <|>
    try (do
        _ <- spaces >> char '('
        a <- spaces >> parseAtom
        _ <- spaces >> char ')'
        return (AtomInterior (AtomComplex a))
    )
    <|>
    try (do
        a <- parseAtomList
        return a
    )
    <|>
    try (do
        a <- spaces >> parseAbstractData
        return (AtomInterior (AtomTrivial a))
    )


parseAtomEnd :: Parser Atom
parseAtomEnd =
    try (do
        at <- spaces >> parseAtomInterior
        return at
    )

-- Terminals Part

parseVar :: Parser AbstractData
parseVar =
    try (do
        h <- upper
        t <- many (alphaNum <|> char '_')
        return (Var (h:t))
    )


parseIdent :: Parser AbstractData
parseIdent =
    try (do -- TODO: Not match "type" and "module"
        h <- (lower <|> char '_')
        t <- many (alphaNum <|> char '_')
        return (Ident (h:t))
    )


-- Module Part

parseModule :: Parser Nonterminal
parseModule =
    try (do
        _  <- spaces >> string "module"
        id <- many1 space >> parseIdent
        _  <- spaces >> char '.'
        return (Module id)
    )


-- Typedefs Part

parseTypedefs :: Parser [Nonterminal]
parseTypedefs = many parseTypedef


parseTypedef :: Parser Nonterminal
parseTypedef =
    try (do
        _     <- spaces >> string "type"
        name  <- spaces >> parseIdent
        typed <- spaces >> parseType
        _     <- spaces >> char '.'
        return (Typedef name typed)
    )


parseType :: Parser Nonterminal
parseType =
    foldr1 Type `fmap` parseList parseTypePart (spaces >> string "->" >> spaces)


parseTypePart :: Parser Nonterminal
parseTypePart =
    try (do
        trv <- spaces >> parseAbstractData
        return (TypeTrivial trv)
    ) 
    <|>
    try (do
        _     <- spaces >> char '('
        typed <- spaces >> parseType
        _     <- spaces >> char ')' >> spaces
        return typed
    )


-- Relations Part

parseRelations :: Parser [Nonterminal]
parseRelations = many parseRelation


parseRelation :: Parser Nonterminal
parseRelation =
    try (do
        h <- spaces >> parseAbstractData
        _ <- spaces >> char '.'
        return (TrivialRelation h)
    )
    <|>
    try (do
        h <- spaces >> parseAbstractData
        _ <- spaces >> string ":-"
        b <- spaces >> parseRelationBody
        _ <- spaces >> char '.'
        return (Relation h b)
    )


parseRelationBody :: Parser Expr
parseRelationBody = fmap (foldr1 Disj) $ parseList parseDisj (char ';')


parseDisj :: Parser Expr
parseDisj = fmap (foldr1 Conj) (parseList parseAbstractExpr (char ','))


parseAbstractExpr :: Parser Expr
parseAbstractExpr =
    try (do
        d <- spaces >> parseAbstractData
        return (AbstractExpr d)
    )


-- Lists Part

parseAtomList :: Parser Atom
parseAtomList =
    try (do
        _ <- spaces >> char '[' >> spaces >> char ']'
        return (AtomBegin (Ident "cons") (AtomEnd (AtomInterior (Ident "nil"))))
    )
    <|>
    try (do
        _    <- spaces >> char '[' >> spaces
        atom <- parseAtomList
        _    <- spaces >> char ']' >> spaces
        return atom
    )
    <|>
    try (do
        _    <- spaces >> char '[' >> spaces
        atom <- parseAtomList'
        _    <- spaces >> char ']' >> spaces
        return atom
    )
    <|>
    try (do
        _    <- spaces >> char '[' >> spaces
        atom <- parseAtomListSpec
        _    <- spaces >> char ']' >> spaces
        return atom
    )


concatAtomLists :: AbstractData -> Atom -> Atom
concatAtomLists x y = (AtomBegin (Ident "cons") (AtomContinue (AtomInterior x) y))


consAtomLists :: [AbstractData] -> Atom
consAtomLists = foldr concatAtomLists (AtomInterior (Ident "nil"))


parseAtomListSpec :: Parser Atom
parseAtomListSpec =
    try (do
        h <- parseAbstractData
        _ <- spaces >> char '|' >> spaces
        t <- parseVar
        return (concatAtomLists h (AtomInterior t))
    )


parseAtomList' :: Parser Atom
parseAtomList' =
    consAtomLists
    `fmap`
    parseList parseAbstractData (spaces >> char ',' >> spaces)


-- Program Part

parseProgram :: Parser Prolog
parseProgram = do
    modl     <- spaces >> parseModule
    typedefs <- spaces >> parseTypedefs
    rels     <- spaces >> parseRelations
    return (Program modl typedefs rels)

prologParser :: Parser Prolog
prologParser =
    parseProgram