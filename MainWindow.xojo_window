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
   HasMaximizeButton=   False
   HasMinimizeButton=   False
   Height          =   140
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   0
   MenuBarVisible  =   False
   MinimumHeight   =   140
   MinimumWidth    =   400
   Resizeable      =   False
   Title           =   "LEDColor"
   Type            =   0
   Visible         =   True
   Width           =   400
   Begin DesktopColorPicker ColorPicker
      HasAlpha        =   True
      Index           =   -2147483648
      LockedInPosition=   False
      Scope           =   0
      TabPanelIndex   =   0
   End
   Begin DesktopOval JoystickLeft
      AllowAutoDeactivate=   True
      BorderColor     =   &c00000000
      BorderThickness =   1.0
      Enabled         =   True
      FillColor       =   &cFFFFFF
      Height          =   100
      Index           =   -2147483648
      Left            =   20
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   3
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Visible         =   True
      Width           =   100
   End
   Begin DesktopOval JoystickRight
      AllowAutoDeactivate=   True
      BorderColor     =   &c000000
      BorderThickness =   1.0
      Enabled         =   True
      FillColor       =   &cFFFFFF
      Height          =   100
      Index           =   -2147483648
      Left            =   280
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      Scope           =   0
      TabIndex        =   4
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Visible         =   True
      Width           =   100
   End
   Begin DesktopCanvas LinkCanvas
      AllowAutoDeactivate=   True
      AllowFocus      =   False
      AllowFocusRing  =   True
      AllowTabs       =   False
      Backdrop        =   0
      Enabled         =   True
      Height          =   100
      Index           =   -2147483648
      Left            =   150
      LockBottom      =   False
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Scope           =   0
      TabIndex        =   6
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   20
      Transparent     =   True
      Visible         =   True
      Width           =   100
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  if Color.IsDarkMode then
		    JoystickLeft.BorderColor = Color.RGB(95,95,95)
		    JoystickRight.BorderColor = Color.RGB(95,95,95)
		  else
		    JoystickLeft.BorderColor = Color.RGB(85,85,85)
		    JoystickRight.BorderColor = Color.RGB(85,85,85)
		  end if
		  
		  ReadColorInfo
		  RunLEDControl
		  PreviousColorLeft = JoystickLeft.FillColor
		  PreviousColorRight = JoystickRight.FillColor
		  
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub BuildArgs()
		  Args.RemoveAll
		  
		  select case ColorChanged
		  case 1
		    'only left joystick has changed color
		    Args.Add("1 " + GetColor(JoystickLeft))
		  case 2
		    'only right joystick has changed color
		    Args.Add("2 " + GetColor(JoystickRight))
		  case 3
		    'both joysticks have changed color
		    if JoystickLeft.FillColor <> JoystickRight.FillColor then
		      'different colors for each joystick
		      Args.Add("1 " + GetColor(JoystickLeft))
		      Args.Add("2 " + GetColor(JoystickRight))
		    else
		      'both has the same color
		      Args.Add("3 " + GetColor(JoystickLeft))
		    end if
		  end select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Clamp(value as Integer, min as Integer, max as Integer) As Integer
		  if value < min then
		    return min
		  elseif value > max then
		    return max
		  else
		    return value
		  end if
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ColorChanged() As Integer
		  var left, right as Integer
		  
		  if JoystickLeft.FillColor <> PreviousColorLeft then
		    left = 1
		  end if
		  
		  if JoystickRight.FillColor <> PreviousColorRight then
		    right = 2
		  end if
		  
		  return left + right
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ControlsDisabled()
		  JoystickLeft.Enabled = False
		  JoystickRight.Enabled = False
		  LinkCanvas.Enabled = False
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ControlsEnabled()
		  JoystickLeft.Enabled = True
		  JoystickRight.Enabled = True
		  LinkCanvas.Enabled = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetColor(joystick as DesktopOval) As String
		  var c as Color = joystick.FillColor
		  var r, g, b as String
		  var t as String = c.ToString '&h00FFFFFF
		  const prefix as string = "&h"
		  
		  t = t.Right(6) 'FFFFFF
		  
		  r = prefix + t.Left(2)
		  g = prefix + t.Middle(2, 2)
		  b = prefix + t.Right(2)
		  
		  r = Str(Val(r))
		  g = Str(Val(g))
		  b = Str(Val(b))
		  
		  return r + " " + g + " " + b
		End Function
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
		    r = Clamp(args(1).ToInteger, 0, 255)
		  end if
		  
		  if args.Count > 2 then
		    g = Clamp(args(2).ToInteger, 0, 255)
		  end if
		  
		  if args.Count > 3 then
		    b = Clamp(args(3).ToInteger, 0, 255)
		  end if
		  
		  Select case args(0).ToInteger
		  case 1
		    JoystickLeft.FillColor = Color.RGB(r, g, b)
		  case 2
		    JoystickRight.FillColor = Color.RGB(r, g, b)
		  case 3
		    JoystickLeft.FillColor = Color.RGB(r, g, b)
		    JoystickRight.FillColor = Color.RGB(r, g, b)
		    Linked = True
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
		Sub RunLEDControl()
		  var sh as new Shell
		  var cmd as String
		  var dir, lc as FolderItem
		  
		  dir = SpecialFolder.Applications.Child("LEDColor").Child("LEDControl")
		  lc = dir.Child("LEDControl.exe")
		  
		  cmd = lc.ShellPath
		  
		  BuildArgs
		  
		  for each args as String in Args
		    sh.TimeOut = 6000
		    sh.Execute(cmd + " " + args)
		  next args
		  
		  ControlsEnabled
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetPreviousColors()
		  PreviousColorLeft = JoystickLeft.FillColor
		  PreviousColorRight = JoystickRight.FillColor
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub WriteColorInfo()
		  var location, file as FolderItem
		  
		  location = SpecialFolder.Preferences.Child("LEDColor")
		  file = location.Child("ColorInfo.txt")
		  
		  if file <> Nil then
		    try
		      var output as TextOutputStream
		      output = TextOutputStream.Create(file)
		      output.Encoding = Encodings.ASCII
		      
		      if GetColor(JoystickLeft) = GetColor(JoystickRight) then
		        output.WriteLine("3 " + GetColor(JoystickLeft))
		      else
		        output.WriteLine("1 " + GetColor(JoystickLeft))
		        output.WriteLine("2 " + GetColor(JoystickRight))
		      end if
		      output.Close
		    end try
		  end if
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		ActiveJoystick As DesktopOval
	#tag EndProperty

	#tag Property, Flags = &h0
		Args() As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Linked As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0
		PreviousColorLeft As Color
	#tag EndProperty

	#tag Property, Flags = &h0
		PreviousColorRight As Color
	#tag EndProperty


#tag EndWindowCode

#tag Events ColorPicker
	#tag Event
		Sub ColorSelected(selectedColor As Color)
		  if Linked then
		    JoystickLeft.FillColor = selectedColor
		    JoystickLeft.Refresh(True)
		    JoystickRight.FillColor = selectedColor
		    JoystickRight.Refresh(True)
		  else
		    if ActiveJoystick <> Nil then
		      ActiveJoystick.FillColor = selectedColor
		      ActiveJoystick.Refresh(True)
		    end if
		  end if
		End Sub
	#tag EndEvent
	#tag Event
		Sub Closed()
		  if ColorChanged > 0 then
		    WriteColorInfo
		    RunLEDControl
		  else
		    ControlsEnabled
		  end if
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events JoystickLeft
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  if x >= 0 and x <= me.Width then
		    if y >= 0 and y <= me.Height then
		      return true
		    end if
		  end If
		End Function
	#tag EndEvent
	#tag Event
		Sub MouseUp(x As Integer, y As Integer)
		  if x >= 0 and x <= me.Width then
		    if y >= 0 and y <= me.Height then
		      ActiveJoystick = me
		      SetPreviousColors
		      ControlsDisabled
		      ColorPicker.HasAlpha = False
		      ColorPicker.Show(ActiveJoystick.FillColor, "Pick a color!")
		    end if
		  end If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events JoystickRight
	#tag Event
		Sub MouseUp(x As Integer, y As Integer)
		  if x >= 0 and x <= me.Width then
		    if y >= 0 and y <= me.Height then
		      ActiveJoystick = me
		      SetPreviousColors
		      ControlsDisabled
		      ColorPicker.HasAlpha = False
		      ColorPicker.Show(ActiveJoystick.FillColor, "Pick a color!")
		    end if
		  end If
		End Sub
	#tag EndEvent
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  if x >= 0 and x <= me.Width then
		    if y >= 0 and y <= me.Height then
		      return true
		    end if
		  end If
		End Function
	#tag EndEvent
#tag EndEvents
#tag Events LinkCanvas
	#tag Event
		Sub MouseUp(x As Integer, y As Integer)
		  if x >= 0 and x <= me.Width then
		    if y >= 0 and y <= me.Height then
		      Linked = not Linked
		      me.Refresh(True)
		      if Linked then
		        if ActiveJoystick <> Nil then
		          if ActiveJoystick.Handle = JoystickLeft.Handle then
		            'active joystick is left
		            JoystickRight.FillColor = ActiveJoystick.FillColor
		            JoystickRight.Refresh
		          else
		            'active joystick is right
		            JoystickLeft.FillColor = ActiveJoystick.FillColor
		            JoystickLeft.Refresh
		          end if
		        else
		          'no active joystick selected
		          JoystickRight.FillColor = JoystickLeft.FillColor
		          JoystickRight.Refresh
		        end if
		        ControlsDisabled
		        WriteColorInfo
		        RunLEDControl
		      end if
		    end if
		  end If
		End Sub
	#tag EndEvent
	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #pragma unused areas
		  
		  if Linked then
		    if Color.IsDarkMode then
		      g.DrawPicture(LinkOnDarkMode, 0, 0, me.Width, me.Height, 0, 0, LinkOnDarkMode.Width, LinkOnDarkMode.Height)
		    else
		      g.DrawPicture(LinkOnLightMode, 0, 0, me.Width, me.Height, 0, 0, LinkOnLightMode.Width, LinkOnLightMode.Height)
		    end if
		  else
		    if Color.IsDarkMode then
		      g.DrawPicture(LinkOffDarkMode, 0, 0, me.Width, me.Height, 0, 0, LinkOffDarkMode.Width, LinkOffDarkMode.Height)
		    else
		      g.DrawPicture(LinkOffLightMode, 0, 0, me.Width, me.Height, 0, 0, LinkOffLightMode.Width, LinkOffLightMode.Height)
		    end if
		  end if
		End Sub
	#tag EndEvent
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  if x >= 0 and x <= me.Width then
		    if y >= 0 and y <= me.Height then
		      return true
		    end if
		  end If
		End Function
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
			"9 - Metal Window"
			"11 - Modeless Dialog"
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
		Name="Linked"
		Visible=false
		Group="Behavior"
		InitialValue=""
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="PreviousColorLeft"
		Visible=false
		Group="Behavior"
		InitialValue="&c000000"
		Type="Color"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="PreviousColorRight"
		Visible=false
		Group="Behavior"
		InitialValue="&c000000"
		Type="Color"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
