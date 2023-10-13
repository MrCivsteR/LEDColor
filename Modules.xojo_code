#tag Module
Protected Module Modules
	#tag CompatibilityFlags = API2Only and ( ( TargetDesktop and ( Target64Bit ) ) )
	#tag Method, Flags = &h0
		Function ClampInt(value as Integer, min as Integer, max as Integer) As Integer
		  if value < min then return min
		  if value > max then return max
		  return value
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function GetColor(x as Integer, y as Integer, width as Integer, height as Integer) As Color
		  'method that returns hsv color value based on x and y values
		  var radius, centerX, centerY, minX, maxX, minY, maxY, midY as Integer
		  var hue, saturation, value as Double
		  var c as Color
		  
		  radius = PickerSize/2
		  centerX = x + radius
		  centerY = y + radius
		  minX = BorderWidth + radius
		  maxX = width - (BorderWidth + radius)
		  minY = minX
		  maxY = height - (BorderWidth + radius)
		  midY = minX + ((maxY - minY)/2)
		  
		  hue = Scale(centerX, minX, maxX, 0, 1)
		  
		  if centerY >= midY then
		    saturation = 1
		  else
		    saturation = Scale(centerY, minY, midY, 0, 1)
		  end if
		  
		  if centerY <= midY then
		    value = 1
		  else
		    value = Scale(centerY, maxY, midY, 0, 1)
		  end if
		  
		  c = Color.HSV(hue, saturation, value)
		  
		  return c
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function InvertColor(c as Color) As Color
		  var newR, newG, newB as Integer
		  
		  newR = 255 - c.Red
		  newG = 255 - c.Green
		  newB = 255 - c.Blue
		  
		  return Color.RGB(newR, newG, newB)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function RGBtoHSV(r as Integer, g as Integer, b as Integer) As Double()
		  var c as Color = Color.RGB(r, g, b)
		  var h, s, v as Double
		  
		  h = c.Hue
		  s = c.Saturation
		  v = c.Value
		  
		  return array(h, s, v)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function Scale(value as Double, valMin as Double, valMax as Double, scaleMin as Double, scaleMax as Double) As Double
		  return scaleMin + (scaleMax - scaleMin) * (value - valMin) / (valMax - valMin)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetLocation(picker as Picker, c as Color, width as Integer, height as Integer)
		  var centerX, centerY, minX, maxX, minY, maxY, midY as Integer
		  var hue, saturation, value as Double
		  
		  centerX = picker.x + (PickerSize/2)
		  centerY = picker.y + (PickerSize/2)
		  minX = BorderWidth + (PickerSize/2)
		  maxX = width - (BorderWidth + (PickerSize/2))
		  minY = minX
		  maxY = height - (BorderWidth + (PickerSize/2))
		  midY = minY + ((maxY - minY)/2)
		  
		  hue = c.Hue
		  saturation = c.Saturation
		  value = c.Value
		  
		  centerX = Scale(hue, 0, 1, minX, maxX)
		  
		  if saturation > 0 and value > 0 then
		    if saturation < 1 and value < 1 then
		      if saturation > value then
		        saturation = 1
		      else
		        value = 1
		      end if
		    end if
		    
		    if saturation >= 1 and value < 1 then
		      centerY = Scale(value, 0, 1, maxY, midY)
		    end if
		    
		    if value >= 1 and saturation < 1 then
		      centerY = Scale(saturation, 0, 1, minY, midY)
		    end if
		    
		    if saturation = value then
		      'saturation and value = 1
		      centerY = midY
		    end if
		  else
		    if saturation = 0 and value = 0 then
		      'black color
		      centerY = maxY
		    else
		      'white color
		      centerY = minY
		    end if
		    
		    select case picker.PickLabel
		    case "L"
		      centerX = minX
		    case "R"
		      centerX = maxX
		    end select
		  end if
		  
		  picker.x = centerX - (PickerSize/2)
		  picker.y = centerY - (PickerSize/2)
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		BorderWidth As Integer = 2
	#tag EndProperty

	#tag Property, Flags = &h0
		PickerSize As Integer = 32
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
			InitialValue="-2147483648"
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
			Name="PickerSize"
			Visible=false
			Group="Behavior"
			InitialValue="32"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderWidth"
			Visible=false
			Group="Behavior"
			InitialValue="2"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
