local lang = vRP.lang
local Luang = module("vrp", "lib/luang")

local basurero = class("basurero", vRP.Extension)

function basurero:__construct()
    vRP.Extension.__construct(self)

    self.cfg = module("vrp_basurero", "cfg/missions")

    -- load lang
    self.luang = Luang()
    self.luang:loadLocale(vRP.cfg.lang, module("vrp_basurero", "cfg/lang/"..vRP.cfg.lang))
    self.lang = self.luang.lang[vRP.cfg.lang]

    -- task: mission
  local function task_mission()
    SetTimeout(60000,task_mission)
    self:taskMission()
  end
  async(function()
    task_mission()
  end)
end

--Basurero
function basurero:taskMission()
  for perm,mission in pairs(self.cfg.trash) do -- each repair perm def
    -- add missions to users
    local users = vRP.EXT.Group:getUsersByPermission(perm)
    for _,user in pairs(users) do
      if user.spawns > 0 and not user:hasMission() then
        -- build mission
        local mdata = {}
        mdata.name = self.lang.trash.title()

        -- generate items
        local todo = 0
        local trash_items = {}
        for fullid,data in pairs(mission.items) do
          local amount = math.random(data[1],data[2]+1)
          if amount > 0 then
            trash_items[fullid] = amount
            todo = todo+1
          end
        end

        local step = {
          text = "",
          onenter = function(player, area)
            for fullid,amount in pairs(trash_items) do
              if amount > 0 then -- check if not done
                if user:tryGiveItem(fullid,amount) then
                  local reward = mission.items[fullid][3]*amount
                  user:giveWallet(reward)
                  vRP.EXT.Base.remote._notify(user.source,lang.money.received({reward}))
                  todo = todo-1
                  trash_items[fullid] = 0
                  if todo == 0 then -- all received, finish mission
                    user:nextMissionStep()
                  end
                end
              end
            end
          end,
          position = mission.positions[math.random(1,#mission.positions)]
        }

        -- mission display
        for fullid,amount in pairs(trash_items) do
            local citem = vRP.EXT.Inventory:computeItem(fullid)
          if citem then
           step.text = step.text..self.lang.trash.item({citem.name,amount}).."<br />"
          end
        end
      

        mdata.steps = {step}

        if todo > 0 then
          user:startMission(mdata)
        end
      end
    end
  end

end

vRP:registerExtension(basurero)