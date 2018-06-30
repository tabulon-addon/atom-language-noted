describe "TODO grammar, with more words", ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage("language-noted")

    runs ->
      grammar = atom.grammars.grammarForScopeName("text.noted")

  it "parses the grammar", ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe "text.noted"
