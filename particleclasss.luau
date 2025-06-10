local Particle = {}
Particle.__index = Particle
-- // Main
do
	function Particle.new(Element, Origin)
		local self = setmetatable({}, Particle)
		--
		self.CurrentRotation = 0
		self.RotationSpeed = 0
		self.Transparency = 0
		self.TimeAlive = 0
		self.Position = Origin or Vector2.new(0, 0)
		self.Velocity = Vector2.new()
		self.Duration = 1
		self.Element = Element
		self.Angle = 0
		self.Size = Vector2.new(15, 15)
		self.Dead = false
		--
		return self
	end
	--
	function Particle:Update(DeltaTime, OnUpdate)
		if self.TimeAlive >= self.Duration and self.Duration > 0 then
			self:Destroy()
			--
			return
		end
		--
		self.TimeAlive = self.TimeAlive + DeltaTime
		--
		OnUpdate(self, DeltaTime)
		--
		self.Element.Position = UDim2.fromOffset(self.Position.X, self.Position.Y)
		self.Element.Rotation = self.CurrentRotation
		self.Element.Size = UDim2.fromOffset(self.Size.X, self.Size.Y)
		--
		self.Element.ImageTransparency = self.Transparency
		self.Element.ImageLabel.ImageTransparency = self.Transparency
	end
	--
	function Particle:Destroy()
		self.Dead = true
		self.Element:Destroy()
	end
end
-- 
return Particle
