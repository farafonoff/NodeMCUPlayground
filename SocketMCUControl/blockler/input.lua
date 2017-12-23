function set_colour_rgb(s)
  local rs,gs,bs = s.match(s, "#(..)(..)(..)");
  setColor(tonumber(rs, 16),tonumber(gs, 16),tonumber(bs, 16));
end

-- Опишите эту функцию…
function _D0_BC_D0_B8_D0_B3_D0_BD_D1_83_D1_82_D1_8C(x)
  set_colour_rgb(x)
  coroutine.yield(500)
end



list = {'#ffffff', '#330099', '#33cc00', '#ffffff', '#cccccc', '#ffcc00', '#c0c0c0', '#ff6600', '#999999', '#ff0000', '#99ffff', '#666666', '#ffcc33', '#333333', '#000000', '#ffcccc', '#ff6666', '#ff0000', '#cc0000', '#330000'}
for _, _D1_86_D0_B2_D0_B5_D1_82 in ipairs(list) do
  _D0_BC_D0_B8_D0_B3_D0_BD_D1_83_D1_82_D1_8C(_D1_86_D0_B2_D0_B5_D1_82)
end
set_colour_rgb('#993300')
