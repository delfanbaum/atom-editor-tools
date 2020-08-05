# To use, copy and paste the following into your init.coffee script,
# which can be found (on a Mac) by selecting Atom -> Init Script...
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# To reload atom, type Ctrl + Option + Cmd + L (on a Mac)

##########################################################################
#                                Shared
##########################################################################

# Add command-pallet ability to remove all text styles from a selection
atom.commands.add 'atom-text-editor', 'remove-text-styles', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  selections = editor.getSelections()
  # are we working in html?
  if `scope  == '.text.html.basic'`
    regMatch = /\<em\>|\<\/em\>|\<code\>|\<\/code\>/g # match em and code
  else # otherwise let's assume we're in markdown or asciidoc, then
    regMatch = /_|\*|`|\+/g # match emphasis, bold, and fixed-width

  striptext = (selection) ->
    selection.insertText(selection.getText().replace(regMatch, ""))

  # use the function
  for selection in selections
    striptext(selection)

##########################################################################
#                                HTMLBook
##########################################################################

#                                Functions
wrapHTML = (selection, tag) ->
  selection.insertText("<#{tag}>#{selection.getText()}</#{tag}>")

wrapHTMLWithClass = (selection, tag, classstr) ->
  tagwithclass = '<' + "#{tag} " + 'class="' + "#{classstr}" + '">'
  selection.insertText("#{tagwithclass}#{selection.getText()}</#{tag}>")

#                                 Commands
# Add emphasis to text in HTML files
atom.commands.add 'atom-text-editor', 'html:add-emphasis', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      wrapHTML(selection, "em")

# Add bold to text in HTML files
atom.commands.add 'atom-text-editor', 'html:add-strong', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      wrapHTML(selection, "strong")

# Add code markup to text in HTML files
atom.commands.add 'atom-text-editor', 'html:add-code-markup', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      wrapHTML(selection, "code")

# Add subscript to text in HTML files
atom.commands.add 'atom-text-editor', 'html:add-subscript', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      wrapHTML(selection, "sub")

# Add superscript to text in HTML files
atom.commands.add 'atom-text-editor', 'html:add-superscript', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      wrapHTML(selection, "sup")

# Add a "keep-together" class to text
atom.commands.add 'atom-text-editor', 'htmlbook:kt-keep-together', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      wrapHTMLWithClass(selection, "span", "keep-together")

# Add "pagebreak-before" class to tag (selected or at cursor)
atom.commands.add 'atom-text-editor', 'htmlbook:pagebreak', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      selection.insertText("#{selection.getText()} class='pagebreak-before'")

# Add "select:labelnumber" xref style to tag (selected or at cursor)
atom.commands.add 'atom-text-editor', 'htmlbook:section-label-number', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.html.basic'`
    selections = editor.getSelections()
    for selection in selections
      selection.insertText("#{selection.getText()} data-xrefstyle='select:labelnumber'")


##########################################################################
#                          Asciidoc/Markdown
##########################################################################

# Useful functions
formatText = (selection, markup, editor) ->
  if selection.getText().slice(0,1) == markup and selection.getText().slice(-1) == markup
    selection.insertText(selection.getText().slice(1,-1))
  else
    wrapped = "#{markup}#{selection.getText()}#{markup}"
    selection.insertText(wrapped)
    if wrapped == "#{markup}#{markup}"
      editor.moveLeft()
    else
      editor.moveLeft(wrapped.length) # go to end of word
      editor.selectRight(wrapped.length)

wrapAdocTag = (selection, tag) ->
  selection.insertText("[.#{tag}]##{selection.getText()}#")


# Generic add class (which you can modify later)
atom.commands.add 'atom-text-editor', 'asciidoc:add-inline-class-(Generic)', ->
    editor = atom.workspace.getActiveTextEditor()
    scope = editor.getRootScopeDescriptor()
    if `scope  == '.source.asciidoc'`
      selections = editor.getSelections()
      for selection in selections
        wrapAdocTag(selection, "class")

# Add a "keep-together" class
atom.commands.add 'atom-text-editor', 'asciidoc:kt-keep-together', ->
    editor = atom.workspace.getActiveTextEditor()
    scope = editor.getRootScopeDescriptor()
    if `scope  == '.source.asciidoc'`
      selections = editor.getSelections()
      for selection in selections
        wrapAdocTag(selection, "keep-together")

# Make text italic
atom.commands.add 'atom-text-editor', 'asciidoc:toggle-italic', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  selections = editor.getSelections()
  for selection in selections
    formatText(selection, "_", editor)

# Make text bold
atom.commands.add 'atom-text-editor', 'asciidoc:toggle-bold', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  if `scope  == '.text.md'`
    bold = "**"
  else
    bold = "*"
  selections = editor.getSelections()
  for selection in selections
    formatText(selection, bold, editor)

# Make bold, code, or other text italic
atom.commands.add 'atom-text-editor', 'asciidoc:force-italic', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  selections = editor.getSelections()
  regMatch = /\*|`|\+/g # match bold, and fixed-width
  striptext = (selection) ->
    selection.insertText(selection.getText().replace(regMatch, "_"))
  for selection in selections
    striptext(selection)

# If you are having trouble with breaking long inline code sections across
# lines, use this command and replace `&#x2060` with `&#x200b` where you
# would like to break the line (mostly works as expected, you may still
# need to play with it)
atom.commands.add 'atom-text-editor', 'asciidoc:force-passthrough-code-letterbreaks', ->
  editor = atom.workspace.getActiveTextEditor()
  scope = editor.getRootScopeDescriptor()
  selections = editor.getSelections()
  regMatch = /`/g # match bold, and fixed-width
  joiner = "&#x2060;"
  if `scope  == '.source.asciidoc'`
    for selection in selections
      selectionText = selection.getText()
      selectionText = selectionText.replace(regMatch, "")
      selectionArray = selectionText.split('')
      selectionText = selectionArray.join(joiner)
      selectionText = "+++<code>" + selectionText + "</code>+++"
      selection.insertText(selectionText)
