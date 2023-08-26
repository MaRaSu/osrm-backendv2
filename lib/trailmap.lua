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
    if width < profile.bicycle_width then
      result.forward_mode = mode.pushing_bike
      result.backward_mode = mode.pushing_bike
      result.forward_speed = profile.walking_speed
      result.backward_speed = profile.walking_speed
    end

    -- check trail_visibility
    local trail_visibility = way:get_value_by_key("trail_visibility")
    if trail_visibility and not profile.bicycle_trail_visibility_tag_whitelist[trail_visibility] then
      result.forward_mode = mode.pushing_bike
      result.backward_mode = mode.pushing_bike
      result.forward_speed = profile.walking_speed
      result.backward_speed = profile.walking_speed
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

return Trailmap