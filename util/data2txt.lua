#!/usr/bin/env lua

-- Parse a lua table in modules/data and write text
-- to run: lua sp.lua "foo"

sptbl = {}
module = arg[1]
dofile(string.format("modules/data/%s.lua", module))
PG = { name = module }

function PG.printheader(self, str)
    io.write(str .. "\n")
    for i = 1, string.len(str) do
        io.write("-")
    end
    io.write("\n\n")
end

function PG.title(self, sp)
    io.write(self.name .. "\n")
    for i = 1, string.len(self.name) do
        io.write("=")
    end
    io.write("\n\n")
end

function PG.desc(self, sp)
    print(sp[self.name].description)
    io.write("\n")
end

function PG.createf(self, sp)
    local tbl = sp[self.name]
    print(string.format("%s(sp_%s **%s)", 
        tbl.func.create, self.name, self.name, tbl.func.init))
end

function PG.destroyf(self, sp)
    local tbl = sp[self.name]
    print(string.format("%s(sp_%s **%s)", 
        tbl.func.destroy, self.name, self.name, tbl.func.init))
end

function PG.initf(self, sp)
    local tbl = sp[self.name]
    
    io.write(string.format("%s(sp_data *sp, sp_%s *%s", 
        tbl.func.init, self.name, self.name))
    tbl = tbl.params.mandatory
    if tbl then
        for _, v in pairs(tbl) do
            if(string.byte(v.type, string.len(v.type)) == 42) then
            arg = string.format(", %s%s", v.type, v.name)
            else
            arg = string.format(", %s %s", v.type, v.name)
            end
            io.write(arg)
        end
    end

    io.write(")\n")
end

function PG.computef(self, sp)
    local tbl = sp[self.name]
    io.write(string.format("%s(sp_data *sp, sp_%s *%s", 
        tbl.func.compute, self.name, self.name, tbl.func.init))
        
    for _, input in pairs(tbl.inputs) do
        io.write(string.format(", SPFLOAT *%s", input.name))
    end

    io.write(")\n")
end


function PG.funcs(self, sp)
    self:printheader("Functions")    
	self:createf(sp)   
	self:initf(sp)   
	self:computef(sp)
	self:destroyf(sp)   
    io.write("\n")
end

function PG.man_params(self,sp)
    local tbl = sp[self.name].params.mandatory
    if tbl then
        self:printheader("Mandatory Parameters")
        for _, v in pairs(tbl) do
            io.write(string.format("%s: ", v.name))
            io.write(v.description)
            io.write(string.format("\n(Recommended value: %s)\n\n", v.default))
        end
    end
end

function PG.opt_params(self,sp)
    local tbl = sp[self.name].params.optional
    if tbl then
        self:printheader("Optional Parameters:")
        for _, v in pairs(tbl) do
            io.write(string.format("*%s*: ", v.name))
            io.write(v.description)
            io.write(string.format("\n(Default value: %s)\n\n", v.default))
        end
    end
end

function PG.inputs(self, sp)
    local tbl = sp[self.name].inputs
    if tbl then
        self:printheader("Inputs:")
        for _, v in pairs(tbl) do
            io.write(string.format("*%s*: ", v.name))
            io.write(v.description .. "\n\n")
        end
	end
end
	
function PG.outputs(self, sp)
    local tbl = sp[self.name].outputs
    if tbl then
        self:printheader("Outputs:")
        for _, v in pairs(tbl) do
            io.write(string.format("*%s*: ", v.name))
            io.write(v.description .. "\n\n")
        end
	end
end

function PG.other(self, sp)
    local tbl = sp[self.name].func.other
    if tbl then
        self:printheader("Other Functions:")
        for func,params in pairs(tbl) do
            io.write(string.format("%s(sp_%s %s", func, self.name, self.name))
            for _,p in pairs(params) do
                io.write(string.format(", %s %s", p.type, p.name))
            end
            io.write(")\n\n")
            for _,p in pairs(params) do
                io.write("*" .. p.name .. ":* ")
                io.write(p.description.. "\n")
                io.write("(Suggested default: " .. p.default .. ")\n\n")
            end
        end
    end
end
	
function PG.params(self, sp)
    PG:man_params(sp)
    PG:opt_params(sp)
    io.write("\n")
end

function PG.makepage(self, sp)
	PG:title(sptbl)
	PG:desc(sptbl)
	PG:funcs(sptbl)
	PG:params(sptbl)
	PG:inputs(sptbl)
	PG:outputs(sptbl)
	PG:other(sptbl)
end

PG:makepage(sptbl)
