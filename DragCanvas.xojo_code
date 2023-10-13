#tag Class
Protected Class DragCanvas
Inherits DesktopCanvas
	#tag CompatibilityFlags = ( TargetDesktop and ( Target32Bit or Target64Bit ) )
	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  'user clicked canvas
		  
		  'find which joystick was hit, and remember mouse xy
		  Dragging = ClickHit(x, y)
		  LastX = x
		  LastY = y
		  
		  BringToFront(Dragging)
		  Refresh
		  
		  return Dragging <> Nil
		  
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(x As Integer, y As Integer)
		  'drag joystick to x, y
		  var oldX, oldY, newX, newY as Integer
		  
		  'mX = Dragging.x + Dragging.Image.Width
		  'mY = Dragging.y + Dragging.Image.Height
		  
		  'var inside as Boolean = _
		  'Dragging.x <= x and x < mX and _
		  'Dragging.y <= y and y < mY
		  
		  if LastX = x and LastY = y then
		    return 'mouse hasn't moved
		  end if
		  
		  oldX = Dragging.x
		  oldY = Dragging.y
		  
		  newX = oldX + x - LastX
		  newY = oldY + y - LastY
		  
		  'update the coordinates and redraw this area
		  if newX - BorderWidth >= 0 and newX + PickerSize + BorderWidth <= me.Width then
		    if newY - BorderWidth >= 0 and newY + PickerSize + BorderWidth <= me.Height then
		      Dragging.x = newX
		      Dragging.y = newY
		    end if
		  end if
		  
		  me.Refresh
		  
		  'remember where the mouse xy for next time around
		  LastX = x
		  LastY = y
		  
		  
		  
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(x As Integer, y As Integer)
		  #pragma unused x
		  #pragma unused y
		  
		  var radius as Integer = PickerSize/2
		  
		  for each picker as Picker in Pickers
		    if Dragging <> picker then
		      if Abs(Dragging.x - picker.x) < radius * 1.5 then
		        if Abs(Dragging.y - picker.y) < radius * 1.5 then
		          'snap dragged picker to other picker
		          Dragging.x = picker.x
		          Dragging.y = picker.y
		          Dragging.PickColor = picker.PickColor
		          me.Refresh
		          exit for picker
		        end if
		      end if
		    end if
		  next picker
		  
		  MainWindow.SetNewColor()
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  #pragma unused areas
		  
		  static initStart as Boolean = True
		  var initLColor, initRColor as Color
		  var doSetNewColor as Boolean
		  
		  DrawHue(g) 'hue layer
		  DrawWhite(g) 'saturation layer
		  DrawBlack(g) 'value layer
		  
		  for each picker as Picker in Pickers
		    
		    'limit picker to canvas bounds
		    if picker.x + PickerSize + 2 > g.Width then picker.x = g.Width - (PickerSize + BorderWidth)
		    if picker.y + PickerSize + 2 > g.Height then picker.y = g.Height - (PickerSize + BorderWidth)
		    
		    'update picker color if being dragged
		    if picker = Dragging then picker.PickColor = GetColor(picker.x, picker.y, g.Width, g.Height)
		    
		    if initStart then 'initial startup run
		      'compare loaded color with current position color
		      'save parameters and colorinfo if colors are different
		      select case picker.PickLabel
		      case "L"
		        initLColor = picker.PickColor
		        if initLColor <> GetColor(picker.x, picker.y, g.Width, g.Height) then
		          doSetNewColor = True
		        end if
		      case "R"
		        initRColor = picker.PickColor
		        if initRColor <> GetColor(picker.x, picker.y, g.Width, g.Height) then
		          doSetNewColor = True
		        end if
		      end select
		      picker.PickColor = GetColor(picker.x, picker.y, g.Width, g.Height)
		    end if
		    
		    g.DrawPicture(picker.Image, picker.x, picker.y)
		    
		  next
		  
		  MainWindow.ColorLeft.Refresh(True)
		  MainWindow.ColorRight.Refresh(True)
		  
		  if doSetNewColor then
		    MainWindow.SetNewColor
		    doSetNewColor = False
		  end if
		  
		  initStart = False
		  
		  #if DebugBuild
		    MainWindow.ShowDebugInfo
		  #endif
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub AddPicker(p as Picture, label as String, x as Integer, y as Integer)
		  var picker as new Picker
		  
		  picker.Image = p
		  picker.PickLabel = label
		  picker.x = x
		  picker.y = y
		  
		  for i as Integer = Pickers.LastIndex DownTo 0
		    if Pickers(i) = picker then return
		  next i
		  
		  Pickers.Add(picker)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub BringToFront(picker as Picker)
		  for i as Integer = Pickers.LastIndex DownTo 0
		    if Pickers(i) = picker then
		      Pickers.RemoveAt(i)
		      Pickers.Add(picker)
		    end if
		  next i
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ClickHit(x as Integer, y as Integer) As Picker
		  'find joystick hit by point xy (if any)
		  
		  for i as Integer = Pickers.LastIndex DownTo 0
		    var picker as Picker = Pickers(i)
		    
		    'check bounds
		    var pickerX as Integer = x - picker.x
		    var pickerY as Integer = y - picker.y
		    var inPicture as Boolean = _
		    0 <= pickerX and pickerX < picker.Image.Graphics.Width and _
		    0 <= pickerY and pickerY < picker.Image.Graphics.Height
		    
		    if inPicture then
		      'opaque pixel?
		      var sx as Double = picker.Image.Graphics.ScaleX
		      var sy as Double = picker.Image.Graphics.ScaleY
		      var pixel as Color = picker.Image.RGBSurface.Pixel(pickerX * sx, pickerY * sy)
		      
		      var alpha as Double = pixel.Alpha
		      if alpha <> 0 then return picker
		    end if
		  next
		  
		  return nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawBlack(g as Graphics)
		  var linearBrush As New LinearGradientBrush
		  var arcSize as Integer = PickerSize + 8
		  
		  linearBrush.StartPoint = New Point((PickerSize/2)+BorderWidth, (PickerSize/2)+BorderWidth)
		  linearBrush.EndPoint = New Point((PickerSize/2)+BorderWidth, g.Height-((PickerSize/2)+BorderWidth))
		  linearBrush.GradientStops.Add(New Pair(0, Color.RGB(0, 0, 0, 255)))
		  linearBrush.GradientStops.Add(New Pair(0.5, Color.RGB(0, 0, 0, 255)))
		  linearBrush.GradientStops.Add(New Pair(1, Color.RGB(0, 0, 0, 0)))
		  
		  g.Brush = linearBrush
		  g.FillRoundRectangle(0, 0, g.Width, g.Height, arcSize, arcSize)
		  
		  g.Brush = nil
		  
		  'draw rounded border
		  g.DrawingColor = Color.FrameColor
		  g.PenSize = BorderWidth
		  g.DrawRoundRectangle(0, 0, g.Width, g.Height, PickerSize+2, PickerSize+2)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawHue(g as Graphics)
		  var linearBrush As New LinearGradientBrush
		  var arcSize as Integer = PickerSize + 8
		  
		  linearBrush.StartPoint = New Point((PickerSize/2)+BorderWidth, (PickerSize/2)+BorderWidth)
		  linearBrush.EndPoint = New Point(g.Width-((PickerSize/2)+BorderWidth), (PickerSize/2)+BorderWidth)
		  linearBrush.GradientStops.Add(New Pair(0, Color.RGB(255, 0, 0)))
		  linearBrush.GradientStops.Add(New Pair(0.166, Color.RGB(255, 255, 0)))
		  linearBrush.GradientStops.Add(New Pair(0.333, Color.RGB(0, 255, 0)))
		  linearBrush.GradientStops.Add(New Pair(0.5, Color.RGB(0, 255, 255)))
		  linearBrush.GradientStops.Add(New Pair(0.666, Color.RGB(0, 0, 255)))
		  linearBrush.GradientStops.Add(New Pair(0.833, Color.RGB(255, 0, 255)))
		  linearBrush.GradientStops.Add(New Pair(1, Color.RGB(255, 0, 0)))
		  
		  g.Brush = linearBrush
		  g.FillRoundRectangle(0, 0, g.Width, g.Height, arcSize, arcSize)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DrawWhite(g as Graphics)
		  var linearBrush As New LinearGradientBrush
		  var arcSize as Integer = PickerSize + 8
		  
		  linearBrush.StartPoint = New Point((PickerSize/2)+BorderWidth, (PickerSize/2)+BorderWidth)
		  linearBrush.EndPoint = New Point((PickerSize/2)+BorderWidth, g.Height-((PickerSize/2)+BorderWidth))
		  linearBrush.GradientStops.Add(New Pair(0, Color.RGB(255, 255, 255, 0)))
		  linearBrush.GradientStops.Add(New Pair(0.5, Color.RGB(255, 255, 255, 255)))
		  linearBrush.GradientStops.Add(New Pair(1, Color.RGB(255, 255, 255, 255)))
		  
		  g.Brush = linearBrush
		  g.FillRoundRectangle(0, 0, g.Width, g.Height, arcSize, arcSize)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Dragging As Picker
	#tag EndProperty

	#tag Property, Flags = &h0
		LastX As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		LastY As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		Pickers() As Picker
	#tag EndProperty


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
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Visible=false
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowAutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Tooltip"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocus"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowTabs"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Transparent"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastX"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LastY"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
