Trailmap = {}


function Trailmap.highway_path_handler(profile,way,result,data)
  -- mtb:scale handling for paths
  if data.highway == "path" then
    local mtb_scale = way:get_value_by_key("mtb:scale")
    local speed = nil

    if mtb_scale and profile.path_mtb_scale_speeds[mtb_scale] then
      speed = math.min(profile.path_mtb_scale_speeds[mtb_scale], result.forward_speed)
    elseif mtb_scale then
      local mtb_scale_number = mtb_scale:match("%d+")
      if mtb_scale_number and profile.path_mtb_scale_speeds[mtb_scale_number] then
        speed = math.min(profile.path_mtb_scale_speeds[mtb_scale_number], result.forward_speed)
      else
      -- mtb:scale was not on the table
      speed = profile.walking_speed
      result.forward_mode = mode.pushing_bike
      result.backward_mode = mode.pushing_bike
      end
    else
      -- no mtb:scale tag
      speed = profile.walking_speed
      result.forward_mode = mode.pushing_bike
      result.backward_mode = mode.pushing_bike
    end
    result.forward_speed = speed
    result.backward_speed = speed
    
    -- check width
    local width = math.huge
    local width_string = way:get_value_by_key("width")
    if width_string and tonumber(width_string:match("%d*%.?%d+")) then
      width = tonumber(width_string:match("%d*%.?%d+"))
    end
    if width < profile.bicycle_width_limit then
      result.forward_mode = mode.pushing_bike
      result.backward_mode = mode.pushing_bike
      result.forward_speed = profile.walking_speed
      result.backward_speed = profile.walking_speed
		elseif width < profile.bicycle_width_threshold then
		  local scaling_factor = (profile.bicycle_width_threshold - width) / (profile.bicycle_width_threshold - profile.bicycle_width_limit)
    	local penalty = (result.forward_speed - profile.walking_speed) * scaling_factor^2
			result.forward_speed = result.forward_speed - penalty
			result.backward_speed = result.backward_speed - penalty
		end


    -- check trail_visibility
    local trail_visibility = way:get_value_by_key("trail_visibility")
    if trail_visibility and not profile.bicycle_trail_visibility_tag_whitelist[trail_visibility] then
      result.forward_mode = mode.pushing_bike
      result.backward_mode = mode.pushing_bike
      result.forward_speed = profile.walking_speed
      result.backward_speed = profile.walking_speed
    end

		-- check obstacle = vegetation
		local obstacle = way:get_value_by_key("obstacle")
		if obstacle and obstacle == "vegetation" then
			result.forward_speed = result.forward_speed * profile.vegetation_penalty
			result.backward_speed = result.backward_speed * profile.vegetation_penalty
		end
  end
end

function Trailmap.highway_track_handler(profile,way,result,data)
  -- mtb:scale handling for tracks
  if data.highway == "track" then
    local mtb_scale = way:get_value_by_key("mtb:scale")
    if mtb_scale and profile.track_mtb_scale_speeds[mtb_scale] then
       result.forward_speed = math.max(profile.track_mtb_scale_speeds[mtb_scale], result.forward_speed)
       result.backward_speed = math.max(profile.track_mtb_scale_speeds[mtb_scale], result.forward_speed)
    elseif mtb_scale then
      local mtb_scale_number = mtb_scale:match("%d+")
      if mtb_scale_number and profile.track_mtb_scale_speeds[mtb_scale_number] then
        result.forward_speed = math.max(profile.track_mtb_scale_speeds[mtb_scale_number], result.forward_speed)
        result.backward_speed = math.max(profile.track_mtb_scale_speeds[mtb_scale_number], result.forward_speed)
      end
    end
  end
end

function Trailmap.adjust_rate_for_surface(profile,way,result,data)
  -- this needs to be after the safety_handler
	if(result.forward_rate and result.backward_rate) then
		local surface = way:get_value_by_key("surface")
		if surface and profile.surface_rate_factor[surface] then
			local surface_factor = profile.surface_rate_factor[surface]
			if result.forward_rate > 0 then
				result.forward_rate = result.forward_rate * surface_factor
			end
			if result.backward_rate > 0 then
				result.backward_rate = result.backward_rate * surface_factor
			end
		end
	end
end

-- reduce speed on bad surfaces, also option for missing surface tag
function Trailmap.surface(profile,way,result,data)
  local surface = way:get_value_by_key("surface")
  local tracktype = way:get_value_by_key("tracktype")
  local smoothness = way:get_value_by_key("smoothness")

  if surface and profile.surface_speeds[surface] then
    result.forward_speed = math.min(profile.surface_speeds[surface], result.forward_speed)
    result.backward_speed = math.min(profile.surface_speeds[surface], result.backward_speed)
	else
		-- if no surface tag, use profile default
		result.forward_speed = math.min(profile.surface_speeds["default"], result.forward_speed)
		result.backward_speed = math.min(profile.surface_speeds["default"], result.backward_speed)
  end
  if tracktype and profile.tracktype_speeds[tracktype] then
    result.forward_speed = math.min(profile.tracktype_speeds[tracktype], result.forward_speed)
    result.backward_speed = math.min(profile.tracktype_speeds[tracktype], result.backward_speed)
  end
  if smoothness and profile.smoothness_speeds[smoothness] then
    result.forward_speed = math.min(profile.smoothness_speeds[smoothness], result.forward_speed)
    result.backward_speed = math.min(profile.smoothness_speeds[smoothness], result.backward_speed)
  end
end

function Trailmap.penalties(profile,way,result,data)
	-- penalize some access tags
  local service_penalty = 1.0
  local service = way:get_value_by_key("service")
  if service and profile.service_penalties[service] then
    service_penalty = profile.service_penalties[service]
  end

  local forward_penalty = service_penalty
  local backward_penalty = service_penalty

	if result.forward_speed > 0 then
		result.forward_speed = result.forward_speed * forward_penalty
	end
	if result.backward_speed > 0 then
		result.backward_speed = result.backward_speed * backward_penalty
	end
end

return Trailmap