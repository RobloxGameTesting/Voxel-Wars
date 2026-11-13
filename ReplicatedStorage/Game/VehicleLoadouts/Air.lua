local function stat(name: string, value: number, text: string)
	return { name = name, value = math.clamp(value, 0, 1), text = text }
end

local function upgrades(scrap: number, scrap2: number)
	return {
		id = "upgrade",
		name = "UPGRADE",
		options = {
			{
				id = "none",
				name = "STANDARD",
				icon = "up_none",
				scrap = 0,
				default = true,
				blurb = "No extra kit. Nothing to trade away.",
				stats = {
					{ name = "ARMOR", value = 0.6, text = "100%" },
					{ name = "FLARES", value = 0.5, text = "20 S" }
				}
			},
			{
				id = "plating",
				name = "ARMOR PLATING",
				icon = "up_plating",
				scrap = scrap,
				rank = 10,
				blurb = "Bullets do a quarter less damage to the hull. Rockets and missiles hit as hard as ever.",
				stats = {
					{ name = "ARMOR", value = 0.8, text = "133%" },
					{ name = "FLARES", value = 0.5, text = "20 S" }
				},
				fx = { roundWear = 0.75 }
			},
			{
				id = "flares",
				name = "QUICK FLARES",
				icon = "up_flares",
				scrap = scrap2,
				rank = 4,
				blurb = "Flares are ready again in 13 seconds, not 20.",
				stats = {
					{ name = "ARMOR", value = 0.6, text = "100%" },
					{ name = "FLARES", value = 0.77, text = "13 S" }
				},
				fx = { flareCooldown = 13 }
			}
		}
	}
end

return {
	{
		id = "Heli",
		name = "HELICOPTER",
		kind = "air",
		slots = {
			{
				id = "gun",
				name = "NOSE GUN",
				options = {
					{
						id = "minigun",
						name = "CHIN MINIGUN",
						icon = "heli_gun_minigun",
						scrap = 0,
						default = true,
						blurb = "Fast stream of bullets. Easy to walk onto a target.",
						stats = {
							{ name = "DAMAGE", value = 0.48, text = "192/S" },
							{ name = "FIRE RATE", value = 0.4, text = "12/S" },
							{ name = "BLAST", value = 0, text = "NONE" }
						}
					},
					{
						id = "cannon",
						name = "AUTOCANNON",
						icon = "heli_gun_cannon",
						scrap = 3000,
						rank = 5,
						blurb = "Slow, heavy shells that burst where they land. Hits hard, but every shot must count.",
						stats = {
							{ name = "DAMAGE", value = 0.6, text = "240/S" },
							{
								name = "FIRE RATE",
								value = 7 / 60,
								text = "3.5/S"
							},
							{ name = "BLAST", value = 0.6, text = "SMALL" }
						},
						fx = {
							card = "CANNON",
							gun = {
								heavy = true,
								rate = 3.5,
								spread = 0.5,
								heat = 1 / 28,
								cool = 0.3,
								coolDelay = 0.6,
								unlock = 0.4,
								blastSize = 0.3,
								blastDamage = 70,
								blastReach = 0.8
							}
						}
					}
				}
			},
			{
				id = "rockets",
				name = "ROCKET PODS",
				options = {
					{
						id = "standard",
						name = "ROCKET PODS",
						icon = "rockets_standard",
						scrap = 0,
						default = true,
						blurb = "Eight rockets that come back one at a time.",
						stats = {
							{
								name = "BLAST",
								value = 15 / 26,
								text = "MEDIUM"
							},
							{ name = "ROCKETS", value = 0.5, text = "8" },
							{ name = "RELOAD", value = 0.7, text = "1.2 S EACH" }
						}
					},
					{
						id = "heavy",
						name = "HEAVY ROCKETS",
						icon = "rockets_heavy",
						scrap = 3500,
						rank = 6,
						blurb = "Four big rockets with a much larger blast. Slow to fire and slow to reload.",
						stats = {
							{
								name = "BLAST",
								value = 21 / 26,
								text = "LARGE"
							},
							{ name = "ROCKETS", value = 0.25, text = "4" },
							{ name = "RELOAD", value = 0.35, text = "2.4 S EACH" }
						},
						fx = {
							rockets = {
								count = 4,
								spacing = 0.55,
								reload = 2.4,
								reloadDelay = 3,
								heavy = 2.1
							}
						}
					},
					{
						id = "rapid",
						name = "SALVO PODS",
						icon = "rockets_rapid",
						scrap = 2500,
						rank = 3,
						blurb = "Twelve rockets fired in one quick burst. Then a long wait to load them again.",
						stats = {
							{
								name = "BLAST",
								value = 15 / 26,
								text = "MEDIUM"
							},
							{ name = "ROCKETS", value = 0.75, text = "12" },
							{ name = "RELOAD", value = 0.4, text = "2.0 S EACH" }
						},
						fx = {
							rockets = { count = 12, spacing = 0.16, reload = 2, reloadDelay = 4 }
						}
					}
				}
			},
			{
				id = "doorgun",
				name = "DOOR GUNS",
				seat = "passenger",
				options = {
					{
						id = "minigun",
						name = "DOOR MINIGUN",
						icon = "door_minigun",
						scrap = 0,
						default = true,
						blurb = "Thirty bullets a second out of the side door. Runs hot in long bursts.",
						stats = {
							{ name = "DAMAGE", value = 0.7, text = "210/S" },
							{ name = "FIRE RATE", value = 1, text = "30/S" },
							{ name = "RANGE", value = 0.45, text = "SHORT" }
						}
					},
					{
						id = "lmg",
						name = "BELT GUN",
						icon = "door_lmg",
						scrap = 1500,
						rank = 2,
						blurb = "Slower, heavier bullets that fly straight and reach far. Hardly ever overheats.",
						stats = {
							{
								name = "DAMAGE",
								value = 2 / 3,
								text = "200/S"
							},
							{
								name = "FIRE RATE",
								value = 1 / 3,
								text = "10/S"
							},
							{ name = "RANGE", value = 0.8, text = "LONG" }
						},
						fx = {
							card = "BELT GUN",
							doorGun = {
								belt = true,
								rate = 10,
								spread = 0.5,
								spinUp = 0.01,
								spinDown = 0.01,
								fireAt = 0,
								heat = 1 / 150,
								cool = 0.25,
								coolDelay = 0.3,
								unlock = 0.5,
								tracerEvery = 2
							}
						}
					},
					{
						id = "launcher",
						name = "GRENADE GUN",
						icon = "door_launcher",
						scrap = 4000,
						rank = 8,
						blurb = "Lobs small explosive shells from the door. Slow, but each one bursts.",
						stats = {
							{
								name = "DAMAGE",
								value = 5 / 6,
								text = "250/S"
							},
							{
								name = "FIRE RATE",
								value = 7 / 60,
								text = "3.5/S"
							},
							{ name = "RANGE", value = 0.65, text = "MEDIUM" }
						},
						fx = {
							card = "GRENADE GUN",
							doorGun = {
								heavy = true,
								rate = 3.5,
								burst = 2,
								spread = 0.6,
								spinUp = 0.01,
								spinDown = 0.01,
								fireAt = 0,
								heat = 1 / 30,
								cool = 0.22,
								coolDelay = 0.5,
								unlock = 0.4,
								tracerEvery = 1,
								blastSize = 0.3,
								blastDamage = 75,
								blastReach = 0.8
							}
						}
					}
				}
			},
			upgrades(4000, 2500)
		}
	},
	{
		id = "StealthHeli",
		name = "STEALTH CHOPPER",
		kind = "air",
		bay = "StealthHeli",
		slots = {
			{
				id = "gun",
				name = "TWIN GUNS",
				options = {
					{
						id = "rotary",
						name = "ROTARY GUNS",
						icon = "stealth_gun_rotary",
						scrap = 0,
						default = true,
						blurb = "Two spinning guns. A wall of light bullets that carries far.",
						stats = {
							{ name = "DAMAGE", value = 0.72, text = "288/S" },
							{ name = "FIRE RATE", value = 1, text = "30/S" },
							{ name = "BLAST", value = 0, text = "NONE" }
						}
					},
					{
						id = "cannon",
						name = "TWIN CANNONS",
						icon = "stealth_gun_cannon",
						scrap = 4500,
						rank = 6,
						blurb = "Two slow cannons whose shells burst where they land. Fewer shots, bigger hits.",
						stats = {
							{ name = "DAMAGE", value = 0.8625, text = "345/S" },
							{
								name = "FIRE RATE",
								value = 1 / 6,
								text = "5/S"
							},
							{ name = "BLAST", value = 0.6, text = "SMALL" }
						},
						fx = {
							card = "CANNONS",
							gun = {
								heavy = true,
								rate = 5,
								spread = 0.4,
								heat = 1 / 36,
								cool = 0.3,
								coolDelay = 0.6,
								unlock = 0.4,
								drop = { "spinUp" },
								blastSize = 0.3,
								blastDamage = 70,
								blastReach = 0.8
							}
						}
					}
				}
			},
			{
				id = "rockets",
				name = "ROCKETS",
				options = {
					{
						id = "heavy",
						name = "HEAVY ROCKETS",
						icon = "rockets_heavy",
						scrap = 0,
						default = true,
						blurb = "Eight heavy rockets, fired fast.",
						stats = {
							{
								name = "BLAST",
								value = 19 / 26,
								text = "LARGE"
							},
							{ name = "ROCKETS", value = 0.5, text = "8" },
							{ name = "RELOAD", value = 0.8, text = "0.9 S EACH" }
						}
					},
					{
						id = "swarm",
						name = "SWARM RACKS",
						icon = "rockets_swarm",
						scrap = 3500,
						rank = 2,
						blurb = "Sixteen lighter rockets that pour out in a stream. Smaller blasts, slower to load.",
						stats = {
							{
								name = "BLAST",
								value = 15 / 26,
								text = "MEDIUM"
							},
							{ name = "ROCKETS", value = 1, text = "16" },
							{ name = "RELOAD", value = 0.6, text = "1.4 S EACH" }
						},
						fx = {
							rockets = {
								count = 16,
								spacing = 0.14,
								reload = 1.4,
								reloadDelay = 4,
								plain = true
							}
						}
					},
					{
						id = "buster",
						name = "BUNKER BUSTERS",
						icon = "rockets_buster",
						scrap = 5000,
						rank = 8,
						blurb = "Three huge rockets that tear a building open. A long wait between each.",
						stats = {
							{ name = "BLAST", value = 1, text = "HUGE" },
							{ name = "ROCKETS", value = 0.1875, text = "3" },
							{ name = "RELOAD", value = 0.25, text = "3.0 S EACH" }
						},
						fx = {
							rockets = {
								count = 3,
								spacing = 0.7,
								reload = 3,
								reloadDelay = 3,
								heavy = 2.6
							}
						}
					}
				}
			},
			upgrades(5000, 3000)
		}
	},
	{
		id = "Jet",
		name = "FIGHTER JET",
		kind = "air",
		bay = "Jet",
		slots = {
			{
				id = "gun",
				name = "CANNON",
				options = {
					{
						id = "rotary",
						name = "ROTARY CANNON",
						icon = "jet_gun_rotary",
						scrap = 0,
						default = true,
						blurb = "A long, tight stream of shells. Fly along a road and little is left on it.",
						stats = {
							{
								name = "FIRE RATE",
								value = 2 / 3,
								text = "20/S"
							},
							{ name = "RANGE", value = 0.8, text = "LONG" }
						}
					},
					{
						id = "burst",
						name = "BURST CANNON",
						icon = "jet_gun_burst",
						scrap = 3500,
						rank = 3,
						blurb = "Fires faster and wider. Easier to hit with in one pass, but it runs hot sooner.",
						stats = {
							{
								name = "FIRE RATE",
								value = 14 / 15,
								text = "28/S"
							},
							{ name = "RANGE", value = 0.6, text = "MEDIUM" }
						},
						fx = {
							gun = {
								rate = 28,
								spread = 0.65,
								heat = 1 / 84
							}
						}
					}
				}
			},
			{
				id = "rockets",
				name = "BOMBS",
				icon = "bombs",
				options = {
					{
						id = "iron",
						name = "IRON BOMBS",
						icon = "bomb_standard",
						scrap = 0,
						default = true,
						blurb = "Four heavy bombs. One comes back every 8 seconds.",
						stats = {
							{ name = "BLAST", value = 0.8, text = "HUGE" },
							{ name = "BOMBS", value = 1, text = "4" },
							{ name = "RELOAD", value = 0.45, text = "8 S EACH" }
						}
					},
					{
						id = "quick",
						name = "QUICK RACKS",
						icon = "bomb_quick",
						scrap = 3000,
						rank = 5,
						blurb = "Smaller bombs that are back on the racks almost twice as fast.",
						stats = {
							{ name = "BLAST", value = 0.6, text = "LARGE" },
							{ name = "BOMBS", value = 1, text = "4" },
							{ name = "RELOAD", value = 0.8, text = "4.5 S EACH" }
						},
						fx = {
							rockets = { reload = 4.5, reloadDelay = 3.5 },
							bomb = { size = 2.2, damage = 260 }
						}
					},
					{
						id = "bunker",
						name = "BUNKER BOMBS",
						icon = "bomb_heavy",
						scrap = 5000,
						rank = 8,
						blurb = "Two bombs that dig a deep crater and hit harder. A long wait for the next pair.",
						stats = {
							{ name = "BLAST", value = 1, text = "HUGE" },
							{ name = "BOMBS", value = 0.5, text = "2" },
							{ name = "RELOAD", value = 0.25, text = "11 S EACH" }
						},
						fx = {
							rockets = { count = 2, spacing = 0.6, reload = 11, reloadDelay = 6 },
							bomb = { damage = 420, cut = "BomberBomb" }
						}
					}
				}
			},
			{
				id = "upgrade",
				name = "UPGRADE",
				options = {
					{
						id = "none",
						name = "STANDARD",
						icon = "up_none",
						scrap = 0,
						default = true,
						blurb = "No extra kit. Nothing to trade away.",
						stats = {
							{ name = "ARMOR", value = 0.6, text = "100%" }
						}
					},
					{
						id = "plating",
						name = "ARMOR PLATING",
						icon = "up_plating",
						scrap = 5000,
						rank = 10,
						blurb = "Bullets do a quarter less damage to the hull. Rockets and missiles hit as hard as ever.",
						stats = {
							{ name = "ARMOR", value = 0.8, text = "133%" }
						},
						fx = { roundWear = 0.75 }
					}
				}
			}
		}
	},
	{
		id = "Bomber",
		name = "STEALTH BOMBER",
		kind = "air",
		bay = "Bomber",
		slots = {
			{
				id = "rockets",
				name = "BOMBS",
				icon = "bombs",
				options = {
					{
						id = "stick",
						name = "BOMB STICK",
						icon = "bomb_standard",
						scrap = 0,
						default = true,
						blurb = "Twelve bombs in a row, four a second.",
						stats = {
							{ name = "BOMBS", value = 1, text = "12" },
							{ name = "RELOAD", value = 0.5, text = "2.5 S EACH" },
							{ name = "RANGE", value = 0.5, text = "MEDIUM" }
						}
					},
					{
						id = "wide",
						name = "LONG STICK",
						icon = "bomb_wide",
						scrap = 4000,
						rank = 3,
						blurb = "The same twelve bombs dropped further apart: a line nearly twice as long.",
						stats = {
							{ name = "BOMBS", value = 1, text = "12" },
							{ name = "RELOAD", value = 0.5, text = "2.5 S EACH" },
							{ name = "RANGE", value = 0.9, text = "LONG" }
						},
						fx = {
							rockets = { spacing = 0.45 }
						}
					},
					{
						id = "quick",
						name = "QUICK BAYS",
						icon = "bomb_quick",
						scrap = 5000,
						rank = 6,
						blurb = "Eight bombs that are back in the bays much sooner. More runs, shorter lines.",
						stats = {
							{
								name = "BOMBS",
								value = 2 / 3,
								text = "8"
							},
							{ name = "RELOAD", value = 0.85, text = "1.5 S EACH" },
							{ name = "RANGE", value = 0.35, text = "SHORT" }
						},
						fx = {
							rockets = { count = 8, reload = 1.5, reloadDelay = 5 }
						}
					}
				}
			},
			{
				id = "upgrade",
				name = "UPGRADE",
				options = {
					{
						id = "none",
						name = "STANDARD",
						icon = "up_none",
						scrap = 0,
						default = true,
						blurb = "No extra kit. Nothing to trade away.",
						stats = {
							{ name = "ARMOR", value = 0.6, text = "100%" }
						}
					},
					{
						id = "plating",
						name = "ARMOR PLATING",
						icon = "up_plating",
						scrap = 6000,
						rank = 10,
						blurb = "Bullets do a quarter less damage to the hull. Rockets and missiles hit as hard as ever.",
						stats = {
							{ name = "ARMOR", value = 0.8, text = "133%" }
						},
						fx = { roundWear = 0.75 }
					}
				}
			}
		}
	}
}