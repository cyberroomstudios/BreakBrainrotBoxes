local Gamepass = {}

export type Gamepass = {
	Name: string,
	Id: number,
}

Gamepass.ENUM = {
	ULTRA_LUCK = {
		Name = "ULTRA_LUCK",
		Id = 1577230052,
	},

	MEGA_LUCK = {
		Name = "MEGA_LUCK",
		Id = 1577754432,
	},

	SUPER_LUCK = {
		Name = "SUPER_LUCK",
		Id = 1577608622,
	},

	BASE_LUCK = {
		Name = "BASE_LUCK",
		Id = 1577506816,
	},
}

function Gamepass:GetEnum(name: string): Gamepass
	return self.ENUM[name]
end

return Gamepass
