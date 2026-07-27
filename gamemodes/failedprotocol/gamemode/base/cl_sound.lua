PrecachedFPSounds = {}

/*---------------------------------------------------------------------------
ClientsideSound( file, ent )

Creates clientside sound handler attached to specified entity. Created sounds are precached.
This function is meant to be accesed by 'PlaySound' net message.

@param 		[string] 		file 		Path to sound file
@param 		[Entity] 		ent 		Parent entity. World Entity if nil

@return 	[CSoundPatch] 	sound 		The sound object
---------------------------------------------------------------------------*/
function ClientsideSound( file, ent )
	if !IsValid( ent ) then
		ent = game.GetWorld()
	end

	if ent == NULL then return end

	local sound
	if !PrecachedFPSounds[file] then
		sound = CreateSound( ent, file, nil )
		PrecachedFPSounds[file] = sound

		return sound
	else
		sound = PrecachedFPSounds[file]
		sound:Stop()

		return sound
	end
end

net.Receive( "PlaySound", function( len )
	local com = net.ReadBool()
	local vol = net.ReadFloat()
	local f = net.ReadString()

	if com then
		local snd = ClientsideSound( f )
		if !snd then return end

		snd:SetSoundLevel( 0 )
		snd:Play()
		snd:ChangeVolume( vol )
	else
		ClientsideSound( f )
	end
end )