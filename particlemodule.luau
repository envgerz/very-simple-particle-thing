local ParticleEmiter = {}
ParticleEmiter.__index = ParticleEmiter
-- // Services
local ReplicatedStorage, RunService = game:GetService("ReplicatedStorage"), game:GetService("RunService")
-- // Modules
local Particle, Fusion = require(script.Particle), require(ReplicatedStorage.Modules.Fusion)
--
local Children, Scoped = Fusion.Children, Fusion.scoped
-- // Variables
local Scope = Scoped(Fusion)
--
local ParticleFrame = Scope:New "ImageLabel" {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(0.5, 0.5),
	--Position = UDim2.fromScale(0.5, 0.5),
	--Parent = ViewportFrame.Glow,
	ZIndex = 0,
	Image = "rbxassetid://12974384137",
	Size = UDim2.fromOffset(15, 15),
	--
	[Children] = Scope:New "ImageLabel" {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ZIndex = 0,
		Image = "rbxassetid://75366152788097",
		Size = UDim2.fromScale(2, 2)
	}
}
--
export type ParticleClass = {
	CurrentRotation : number,
	RotationSpeed : number,
	Transparency : number,
	TimeAlive : number,
	Velocity : Vector2,
	Position : Vector2,
	Duration : number,
	Element : GuiBase2d,
	Angle : number,
	Dead : boolean,
	Size : Vector2
}
-- // Main
do
	local function SpawnParticle(Parent, Element, OnSpawn, Origin)
		local Particle = Particle.new(Element:Clone(), Origin)
		--
		Particle.Element.Position = UDim2.fromOffset(Origin.X, Origin.Y)
		Particle.Element.Parent = Parent
		OnSpawn(Particle)
		--
		return Particle
	end
	--
	function ParticleEmiter.new(Parent : GuiBase2d, Rate : number, ParticleElement : GuiBase2d?)
		local self = setmetatable({}, ParticleEmiter)
		--
		self.Particles = {} :: Particle
		self.Element = ParticleElement or ParticleFrame
		self.Origin = Vector2.new(Parent.AbsoluteSize.X / 2, Parent.AbsoluteSize.Y / 2)
		self.Parent = Parent
		self.Rate = Rate or 5
		--
		self.OnSpawn = function(Particle : ParticleClass) end :: (ParticleClass)->nil
		self.OnUpdate = function(Particle : ParticleClass, DeltaTime) end :: (ParticleClass, DeltaTime : number)->nil
		--
		self.__TotalTime = 0
		self.__Dead = false
		--
		self.__Connection = RunService.PreRender:Connect(function(DeltaTime)
			self.__TotalTime = self.__TotalTime + DeltaTime
			--
			for Index, Value in self.Particles do
				if Value.Dead then
					table.remove(self.Particles, Index)
				else
					Value:Update(DeltaTime, self.OnUpdate)
				end
			end
			--
			if self.Rate > 0 then
				while self.__TotalTime >= (1 / self.Rate) do
					self:Emit(1)
					--
					self.__TotalTime = self.__TotalTime - (1 / self.Rate)
				end
			end
		end)
		--
		return self
	end
	--
	function ParticleEmiter:Emit(Count)
		if Count <= 0 then return end
		--
		for Index = Count, 1, -1 do
			table.insert(self.Particles, SpawnParticle(self.Parent, self.Element, self.OnSpawn, self.Origin))
		end
	end
	--
	function ParticleEmiter:Destroy()
		if self.__Dead then return end
		--
		self.__Dead = true
		--
		for Index, Value in self.Particles do
			Value:Destroy()
		end
		--
		self.__Connection:Disconnect()
	end
end
--
return ParticleEmiter
