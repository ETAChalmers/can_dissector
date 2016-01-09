local p_auml = Proto.new("auml", "Auml CAN format")

local f_cmd = ProtoField.uint8("auml.cmd", "Command ID", base.DEC)

p_auml.fields = {
    f_cmd
}

-- Fields to read
local f_can_id = Field.new("can.id")
local f_can_xtd = Field.new("can.flags.xtd")

-- For sub dissectors
local auml_cmd_tbl = DissectorTable.new("auml.cmd", "Auml Command")

function p_auml.dissector(tvb,pinfo,tree)
    local can_id = f_can_id()
    local can_xtd = f_can_xtd()

    -- we only care about extended frames
    if not can_xtd then return end

    local subt = tree:add(p_auml,tvb)
    local cmd_tvbr = can_id.tvb:bitfield(3,4)
    subt:add(f_cmd, cmd_tvbr)

    pinfo.cols.protocol = "   "

    -- to dissect further, call sub dissector
    auml_cmd_tbl:try(cmd_tvbr, tvb, pinfo, tree)
end

DissectorTable.get("can.subdissector"):add(0,p_auml)
