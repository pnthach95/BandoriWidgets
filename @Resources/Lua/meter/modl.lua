
-- https://github.com/inuyaksa/jquery.nicescroll
-- @author F4Jonatas
-- @license GPL v2.0 License

local meter = require( 'meter' )


local modlscroll = {
	-- move scroll postion
	-- offset = function( self ) end

	-- change scroll position
	class = {
		move = function( self, left, top )
			self.vthumb:rectangle( 1, top, self.width, self.height )
			SKIN:Bang( '!updatemeter', 'modl:scroll.shape' )
		end,



		hidden = function( self, bool )
			if self.vthumb then
				if bool == false then
					self.vthumb:fill( 72, 72, 72 )
					self.vtrack:fill( 54, 54, 54 )
					SKIN:Bang( '!updatemeter', 'modl:scroll.shape' )
					return self
				end

				self.vthumb:fill( 0, 0, 0, 0 )
				self.vtrack:fill( 0, 0, 0, 0 )
				SKIN:Bang( '!updatemeter', 'modl:scroll.shape' )
				return self
			end
		end
	}
}

modlscroll.__index = modlscroll.class




local modl = {
	-- __index = modl,

	control = {
		-- x01 = modl:scroll.group
		-- x02 = modl:scroll.shape

		-- x03 = modl:background.shape
	},



	scrollbar = function( self, options )
		local class = {
			vpos = 0,
			hpos = 0
		}


		-- get meter necessary
		self.control.x01 = meter( 'modl:scroll.group' )
		self.control.x02 = meter( 'modl:scroll.shape' )


		-- extremely necessary meter
		if self.control.x01 == -1 or self.control.x02 == -1
		or self.control.x01:option( 'meter' ):lower() ~= 'image'
		or self.control.x02:option( 'meter' ):lower() ~= 'shape' then
			print( '--' )
			print( '+--+-- modl:scroll.shape type: shape' )
			print( '+--+-- modl:scroll.group type: image' )
			print( '+--+ Extremely necessary meters:' )
			print( '+ modl:scrollbar error: -1' )
			return -1

		elseif not self.control.x02:option( 'container' )
		or self.control.x02:option( 'container' ):lower() ~= 'modl:scroll.group' then
			print( '--' )
			print( '+-- Extremely necessary container = "modl:scroll.group"' )
			print( '+ modl:scrollbar error: -2' )
			return -2
		end


		-- get and set options
		if options and options.groupwidth then
			self.control.x01:option( 'w', options.groupwidth )
			class.groupwidth = options.groupwidth

		else class.groupwidth = self.control.x01:option( 'w' )
		end

		if options and options.groupheight then
			self.control.x01:option( 'h', options.groupheight )
			class.groupheight = options.groupheight

		else class.groupheight = self.control.x01:option( 'h' )
		end

		if options and options.groupleft then
			self.control.x01:option( 'x', options.groupleft )
			class.groupleft = options.groupleft

		else class.groupleft = self.control.x01:option( 'x' )
		end

		if options and options.grouptop then
			self.control.x01:option( 'y', options.grouptop )
			class.grouptop = options.grouptop

		else class.grouptop = self.control.x01:option( 'y' )
		end


		if options and options.left then
			self.control.x02:option( 'x', options.left )
			class.left = options.left

		else class.left = self.control.x01:option( 'x' )
		end

		if options and options.top then
			self.control.x02:option( 'y', options.top )
			class.top = options.top

		else class.top = self.control.x01:option( 'y' )
		end

		class.height = ( options and options.height ) and options.height or 238
		class.width  = ( options and options.width  ) and options.width  or 11
		class.left   = ( options and options.left   ) and options.left   or 1


		-- create or get scroll vertical
		class.vtrack = shape( 'modl:scroll.shape' )
		class.vtrack:rectangle( 6, 0, 2, class.groupheight - 2 )
			:fill( 54, 54, 54 )
			:strokewidth( 0 )

		class.vthumb = shape( 'modl:scroll.shape', 2 )
		class.vthumb:rectangle( class.left, 0, class.width, class.height )
			:fill( 72, 72, 72 )
			:strokewidth( 0 )


		self.control.x01:update()
		self.control.x02:update()

		return setmetatable( class, modlscroll )
	end,



	background = function( self, options )
		-- get meter necessary
		self.control.x03 = meter( 'modl:background.shape' )

		-- extremely necessary meter
		if self.control.x03 == -1
		or self.control.x03:option( 'meter' ):lower() ~= 'shape' then
			print( '--' )
			print( '+--+-- modl:background.shape type: shape' )
			print( '+--+ Extremely necessary meter:' )
			print( '+ modl:background error: -1' )
			return -1
		end



	end
}









setmetatable( modl, {
	__tostring = tostring,


	--[[
		modl(
			[string/required] Measure name
			[boolean/optional] If true, any errors will be shown in the log
		)
	--]]
	__call = function( self, name, dbug )
		local class = {}
		class.dbug = dbug
		class.shape = shape( name )


		--[[
			modl:rect(
				[table/integer/required] If table options. If integer: left
				[integer/optional]       Top
				[integer/optional]       Width
				[integer/optional]       Height
				[integer/optional]       RadiusX
				[integer/optional]       RadiusY
			)

			Ex with integer: modl:rect( 0, 0, 152, 366 )
			Ex with table: modl:rect({
				fill = "10, 10, 10, 100",
				strokewidth = 0,
				height = 366,
				width = 152
			})
		--]]
		-- class.rect = function( sefl, ... )
		-- 	if #arg == 1 then
		-- 	end
		-- end

		return self
	end
})

return modl
