#tag DesktopWindow
Begin DesktopWindow MainWindow
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   Height          =   344
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   False
   MinimumHeight   =   344
   MinimumWidth    =   600
   Resizeable      =   True
   Title           =   "LEDColor"
   Type            =   0
   Visible         =   True
   Width           =   600
   Begin DragCanvas MainCanvas
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Height          =   234
      Index           =   -2147483648
      LastX           =   0
      LastY           =   0
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   20
      Transparent     =   True
      Visible         =   True
      Width           =   560
   End
   Begin DesktopCanvas ColorLeft
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Height          =   50
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   False
      Scope           =   0
      TabIndex        =   12
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   274
      Transparent     =   True
      Visible         =   True
      Width           =   160
   End
   Begin DesktopCanvas ColorRight
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Height          =   50
      Index           =   -2147483648
      Left            =   420
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   False
      LockRight       =   True
      LockTop         =   False
      Scope           =   0
      TabIndex        =   13
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   274
      Transparent     =   True
      Visible         =   True
      Width           =   160
   End
   Begin DesktopLabel Label1
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   42
      Index           =   -2147483648
      Italic          =   False
      Left            =   192
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   False
      Multiline       =   True
      Scope           =   0
      Selectable      =   False
      TabIndex        =   14
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   2
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   282
      Transparent     =   False
      Underline       =   False
      Visible         =   True
      Width           =   216
   End
   Begin DesktopXAMLContainer XAMLRing
      AllowAutoDeactivate=   True
      Content         =   "<winui:ProgressRing IsActive='True' />\r"
      Enabled         =   True
      Height          =   50
      Index           =   -2147483648
      InitialParent   =   ""
      Left            =   275
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   15
      TabPanelIndex   =   0
      Tooltip         =   ""
      Top             =   274
      Transparent     =   False
      Visible         =   False
      Width           =   50
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  OpenParameters
		  ReadParameters
		  SetupCanvas
		  System.DebugLog "Started..."
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resized()
		  static initStart as Boolean = True
		  
		  if not initStart then
		    SetNewColor
		    System.DebugLog "Resized"
		  end if
		  
		  initStart = False
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resizing()
		  var width, height as Integer
		  
		  width = MainCanvas.Width
		  height = MainCanvas.Height
		  
		  for each picker as Picker in MainCanvas.Pickers
		    if picker <> MainCanvas.Dragging then
		      picker.PickColor = GetColor(picker.x, picker.y, width, height)
		    end if
		  next
		  System.DebugLog "Resizing..."
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub CreateNewParams(file as FolderItem)
		  var sql as String = "CREATE TABLE Pickers (ID INTEGER NOT NULL, Label TEXT, X INTEGER, Y INTEGER, Color TEXT, PRIMARY KEY(ID));"
		  
		  Parameters = new SQLiteDatabase
		  Parameters.DatabaseFile = file
		  
		  try
		    Parameters.CreateDatabase
		    Parameters.Connect
		    Parameters.ExecuteSQL(sql) 'add table
		    
		    var leftPicker as new DatabaseRow
		    var rightPicker as new DatabaseRow
		    var x, y, radius, width, height as Integer
		    
		    'add rows with default values
		    width = MainCanvas.Width
		    height = MainCanvas.Height
		    radius = PickerSize/2
		    
		    y = (height/2)-radius
		    
		    leftPicker.Column("Label") = "L"
		    x = ((width/2)-radius) * 0.5
		    leftPicker.Column("X") = x
		    leftPicker.Column("Y") = y
		    leftPicker.Column("Color") = Str(GetColor(x, y, width, height))
		    
		    rightPicker.Column("Label") = "R"
		    x = ((width/2)-radius) * 1.5
		    rightPicker.Column("X") = x
		    rightPicker.Column("Y") = y
		    rightPicker.Column("Color") = Str(GetColor(x, y, width, height))
		    
		    Parameters.AddRow("Pickers", leftPicker)
		    Parameters.AddRow("Pickers", rightPicker)
		    
		  catch e as DatabaseException
		    System.DebugLog "SQLite Error: " + e.Message
		  end try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function FillColor(g as Graphics, picker as Picker) As Color
		  var centerX, centerY, radius, line1X, line1Y, line2X, line2Y as Integer
		  var rStr, gStr, bStr, line1, line2 as String
		  var currentColor as Color
		  
		  radius = PickerSize/2
		  
		  currentColor = picker.PickColor
		  rStr = currentColor.Red.ToString
		  gStr = currentColor.Green.ToString
		  bStr = currentColor.Blue.ToString
		  
		  centerX = picker.x + radius
		  centerY = picker.y + radius
		  
		  g.DrawingColor = currentColor
		  g.FillRoundRectangle(0, 0, g.Width, g.Height-1, radius, radius)
		  
		  line1 = Right(currentColor.ToString, 6) 'hex value
		  line2 = _ 'rgb value
		  "R:" + rStr + ", " + _
		  "G:" + gStr + ", " + _
		  "B:" + bStr
		  
		  g.DrawingColor = InvertColor(currentColor)
		  g.Bold = True
		  
		  line1X = 0.5 * (g.Width - g.TextWidth (line1))
		  line1Y = 0.5 * (g.height - (g.TextHeight*2)) + g.TextAscent
		  
		  line2X = 0.5 * (g.Width - g.TextWidth (line2))
		  line2Y = 0.5 * (g.height) + g.TextAscent
		  
		  g.DrawText(line1, line1X, line1Y)
		  g.DrawText(line2, line2X, line2Y)
		  
		  return currentColor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetRGBString(c as Color) As String
		  'return r, g, and b string values of color
		  var r, g, b as String
		  
		  r = c.Red.ToString
		  g = c.Green.ToString
		  b = c.Blue.ToString
		  
		  return r + " " + g + " " + b
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub OpenParameters()
		  var paramFile as FolderItem
		  
		  #if DebugBuild
		    paramFile = SpecialFolder.Desktop.Child("parameters.db")
		  #else
		    paramFile = SpecialFolder.CurrentWorkingDirectory.Child("parameters.db")
		  #endif
		  
		  if not paramFile.Exists then
		    CreateNewParams(paramFile)
		  else
		    try
		      Parameters = new SQLiteDatabase
		      Parameters.DatabaseFile = paramFile
		      Parameters.Connect
		    catch e as DatabaseException
		      System.DebugLog "SQLite Error: " + e.Message
		    end try
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ParseLine(line as String)
		  var args() as String
		  var r, g, b as Integer
		  
		  r = 0
		  b = 0
		  g = 0
		  args = line.Split(" ")
		  
		  if args(0).Length > 1 then
		    args(0) = args(0).RightBytes(1)
		  end if
		  
		  if args.Count > 1 then
		    r = ClampInt(args(1).ToInteger, 0, 255)
		  end if
		  
		  if args.Count > 2 then
		    g = ClampInt(args(2).ToInteger, 0, 255)
		  end if
		  
		  if args.Count > 3 then
		    b = ClampInt(args(3).ToInteger, 0, 255)
		  end if
		  
		  Select case args(0).ToInteger
		  case 1
		    RGBLeft = Color.RGB(r, g, b)
		  case 2
		    RGBRight = Color.RGB(r, g, b)
		  case 3
		    RGBLeft = Color.RGB(r, g, b)
		    RGBRight = Color.RGB(r, g, b)
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReadColorInfo()
		  var location, file as FolderItem
		  
		  location = SpecialFolder.Preferences.Child("LEDColor")
		  file = location.Child("ColorInfo.txt")
		  
		  if file <> nil and file.Exists then
		    var input as TextInputStream
		    input = TextInputStream.Open(file)
		    input.Encoding = Encodings.ASCII
		    while not input.EndOfFile
		      ParseLine(input.ReadLine)
		    wend
		    input.Close
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ReadParameters()
		  if Parameters = Nil then return
		  
		  var rows as RowSet
		  
		  try
		    rows = Parameters.SelectSQL("SELECT Label, X, Y, Color FROM Pickers")
		    for each row as DatabaseRow in rows
		      var picker as new Picker
		      
		      picker.PickLabel = row.Column("Label").StringValue
		      picker.x = row.Column("X").IntegerValue
		      picker.y = row.Column("Y").IntegerValue
		      var c as Variant = row.Column("Color").StringValue
		      picker.PickColor = c.ColorValue
		      
		      MainCanvas.Pickers.Add(picker)
		    next row
		    
		  catch e as DatabaseException
		    System.DebugLog "SQLite Error: " + e.Message
		  end try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RunLEDControl()
		  var sh as new Shell
		  var cmd as String
		  var dir, exe as FolderItem
		  
		  #if DebugBuild then
		    dir = SpecialFolder.Applications.Child("LEDColor").Child("LEDControl")
		  #else
		    dir = SpecialFolder.CurrentWorkingDirectory.Child("LEDControl")
		  #endif
		  exe = dir.Child("LEDControl.exe")
		  
		  cmd = exe.ShellPath
		  
		  sh.TimeOut = 6000
		  XAMLRing.Visible = True
		  sh.Execute cmd
		  XAMLRing.Visible = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetNewColor()
		  for each picker as Picker in MainCanvas.Pickers
		    UpdateParameters(picker)
		  next picker
		  
		  WriteColorInfo
		  RunLEDControl
		  
		  #if DebugBuild
		    ShowDebugInfo
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetupCanvas()
		  var x, y, radius, textX, textY as Integer
		  var txt as String
		  
		  radius = PickerSize/2
		  y = (MainCanvas.Height/2)-radius
		  
		  for each picker as Picker in MainCanvas.Pickers
		    var p as Picture = BitmapForCaching(PickerSize, PickerSize)
		    
		    select case picker.PickLabel
		    case "L"
		      txt = "L"
		      x = ((MainCanvas.Width/2)-radius) * 0.5
		      RGBLeft = picker.PickColor
		    case "R"
		      txt = "R"
		      x = ((MainCanvas.Width/2)-radius) * 1.5
		      RGBRight = picker.PickColor
		    end select
		    
		    p.Graphics.DrawingColor = &cffffff60 'fill color
		    p.Graphics.FillOval(0, 0, PickerSize, PickerSize)
		    
		    p.Graphics.DrawingColor = &c00000060 'border and text color
		    p.Graphics.FontSize = PickerSize * 3/4
		    p.Graphics.PenSize = 2
		    p.Graphics.DrawOval(0, 0, PickerSize, PickerSize)
		    
		    textX = radius - (p.Graphics.TextWidth(txt)/2)
		    textY = radius - (p.Graphics.TextHeight/2) + (p.Graphics.FontAscent-2)
		    p.Graphics.DrawText(txt, textX, textY)
		    
		    picker.Image = p
		    
		  next picker
		  
		  #if DebugBuild
		    ShowDebugInfo
		  #endif
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ShowDebugInfo()
		  var radius as Integer
		  var line1, line2 as String
		  
		  radius = PickerSize/2
		  
		  for each picker as Picker in MainCanvas.Pickers
		    select case picker.PickLabel
		    case "L"
		      line1 = "Left - CenterX:" + Format(picker.x + radius, "-0") + ", CenterY:" + Format(picker.y + radius, "-0") + EndOfLine
		    case "R"
		      line2 = "Right - CenterX:" + Format(picker.x + radius, "-0") + ", CenterY:" + Format(picker.y + radius, "-0")
		    end select
		  next picker
		  
		  Label1.Text = line1 + line2
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub UpdateParameters(picker as Picker)
		  var sql as String
		  
		  sql = "UPDATE Pickers SET X=?, Y=?, Color=? WHERE Label =?"
		  
		  try
		    Parameters.ExecuteSQL(sql, picker.x.ToString, picker.y.ToString, picker.PickColor.ToString, picker.PickLabel)
		  catch e as DatabaseException
		    System.DebugLog "SQLite Error: " + e.Message
		  end try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteColorInfo()
		  var location, file as FolderItem
		  var leftColor, rightColor as Color
		  var cmd1, cmd2 as String
		  
		  location = SpecialFolder.Preferences.Child("LEDColor")
		  if not location.Exists then location.CreateFolder
		  
		  file = location.Child("ColorInfo.txt")
		  
		  if file <> Nil then
		    try
		      var output as TextOutputStream
		      output = TextOutputStream.Create(file)
		      output.Encoding = Encodings.ASCII
		      
		      for each picker as Picker in MainCanvas.Pickers
		        select case picker.PickLabel
		        case "L"
		          leftColor = picker.PickColor
		        case "R"
		          rightColor = picker.PickColor
		        end select
		      next picker
		      
		      if leftColor = rightColor then
		        cmd1 = "3 " + GetRGBString(leftColor)
		        output.WriteLine(cmd1)
		        System.DebugLog cmd1
		      else
		        cmd1 = "1 " + GetRGBString(leftColor)
		        cmd2 = "2 " + GetRGBString(rightColor)
		        output.WriteLine(cmd1)
		        output.WriteLine(cmd2)
		        System.DebugLog cmd1
		        System.DebugLog cmd2
		      end if
		      output.Close
		    catch e as IOException
		      System.DebugLog "IO Error: " + e.Message
		    end try
		  end if
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Parameters As SQLiteDatabase
	#tag EndProperty

	#tag Property, Flags = &h0
		RGBLeft As Color
	#tag EndProperty

	#tag Property, Flags = &h0
		RGBRight As Color
	#tag EndProperty


#tag EndWindowCode

#tag Events ColorLeft
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #pragma unused areas
		  
		  var radius as Integer
		  
		  radius = PickerSize/2
		  
		  for each picker as Picker in MainCanvas.Pickers
		    if picker.PickLabel = "L" then
		      RGBLeft = FillColor(g, picker)
		      return
		    end if
		  next picker
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ColorRight
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #pragma unused areas
		  
		  var radius as Integer
		  
		  radius = PickerSize/2
		  
		  for each picker as Picker in MainCanvas.Pickers
		    if picker.PickLabel = "R" then
		      RGBRight = FillColor(g, picker)
		      return
		    end if
		  next picker
		End Sub
	#tag EndEvent
#tag EndEvents
#tag ViewBehavior
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=false
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="2"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Windows Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&cFFFFFF"
		Type="ColorGroup"
		EditorType="ColorGroup"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="DesktopMenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="RGBRight"
		Visible=false
		Group="Behavior"
		InitialValue="&c000000"
		Type="Color"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="RGBLeft"
		Visible=false
		Group="Behavior"
		InitialValue="&c000000"
		Type="Color"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
