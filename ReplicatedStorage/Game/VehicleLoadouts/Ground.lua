local function stat(name: string, p: number, text: string?)
	return { name = name, value = p, text = text }
end
return {
	{
		id = "Tank",
		name = "TANK",
		kind = "ground",
		slots = {
			{
				id = "shell",
				name = "MAIN GUN",
				options = {
					{
						id = "he",
						name = "HE SHELL",
						blurb = "A big blast. Best against soldiers and buildings.",
						icon = "shell_he",
						scrap = 0,
						default = true,
						stats = {
							{ name = "BLAST", value = 1, text = "25" },
							{ name = "VS VEHICLES", value = 0.6, text = "100%" },
							{ name = "SHELL SPEED", value = 0.67, text = "1400" }
						}
					},
					{
						id = "ap",
						name = "AP SABOT",
						blurb = "A fast steel dart that flies flat and tears through vehicles. Almost no blast.",
						icon = "shell_ap",
						scrap = 4000,
						rank = 6,
						stats = {
							{ name = "BLAST", value = 0.28, text = "7" },
							{ name = "VS VEHICLES", value = 1, text = "160%" },
							{ name = "SHELL SPEED", value = 1, text = "2100" }
						},
						fx = {
							cannon = {
								speed = 2100,
								drag = 0.0008,
								size = 0.7,
								hullWear = 3.43,
								damage = 240,
								blast = {
									inner = 2,
									radius = 7,
									low = 20,
									shock = 2,
									shockRadius = 10
								}
							}
						}
					},
					{
						id = "mp",
						name = "MULTI-PURPOSE",
						blurb = "A bit of both: a smaller blast and more bite on vehicles.",
						icon = "shell_mp",
						scrap = 2500,
						rank = 2,
						stats = {
							{ name = "BLAST", value = 0.64, text = "16" },
							{ name = "VS VEHICLES", value = 0.8, text = "130%" },
							{ name = "SHELL SPEED", value = 0.81, text = "1700" }
						},
						fx = {
							cannon = {
								speed = 1700,
								drag = 0.0012,
								size = 1.2,
								hullWear = 1.625,
								damage = 200,
								blast = {
									inner = 3.5,
									radius = 16,
									low = 28,
									shock = 2,
									shockRadius = 24
								}
							}
						}
					}
				}
			},
			{
				id = "roof",
				name = "ROOF GUN",
				options = {
					{
						id = "minigun",
						name = "MACHINE GUN",
						blurb = "Fast and steady. Keeps soldiers off your tank.",
						icon = "roof_minigun",
						scrap = 0,
						default = true,
						stats = {
							{ name = "FIRE RATE", value = 1, text = "600" },
							{ name = "PUNCH", value = 0.35, text = nil },
							{ name = "VS VEHICLES", value = 0.1, text = nil }
						}
					},
					{
						id = "hmg",
						name = "HEAVY MG",
						blurb = "Slow, heavy rounds that burst where they land and hurt light vehicles.",
						icon = "roof_hmg",
						scrap = 3000,
						rank = 4,
						stats = {
							{ name = "FIRE RATE", value = 0.4, text = "240" },
							{ name = "PUNCH", value = 1, text = nil },
							{ name = "VS VEHICLES", value = 0.6, text = nil }
						},
						fx = {
							gun = {
								heavy = true,
								rate = 4,
								burst = 3,
								spread = 0.5,
								heat = 1 / 44,
								cool = 0.22,
								coolDelay = 0.4,
								unlock = 0.4,
								tracerEvery = 1,
								blastSize = 0.3,
								blastDamage = 130,
								blastReach = 0.8,
								kick = 0.6,
								climb = 0.1
							}
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
						blurb = "The tank as it rolls out of the factory.",
						icon = "up_none",
						scrap = 0,
						default = true,
						stats = {
							{ name = "ARMOR", value = 0.7, text = "100%" },
							{ name = "RELOAD", value = 0.6, text = "3.5 S" }
						}
					},
					{
						id = "plating",
						name = "REACTIVE PLATING",
						blurb = "Extra plates soak up rockets and shells: blasts hurt the hull 10% less.",
						icon = "up_plating",
						scrap = 5000,
						rank = 8,
						stats = {
							{ name = "ARMOR", value = 0.78, text = "110%" },
							{ name = "RELOAD", value = 0.6, text = "3.5 S" }
						},
						fx = { blastWear = 0.9 }
					},
					{
						id = "loader",
						name = "FAST LOADER",
						blurb = "The next shell is ready half a second sooner.",
						icon = "up_loader",
						scrap = 6000,
						rank = 10,
						stats = {
							{ name = "ARMOR", value = 0.7, text = "100%" },
							{ name = "RELOAD", value = 0.75, text = "3.0 S" }
						},
						fx = {
							refillK = 6 / 7
						}
					}
				}
			}
		}
	},
	{
		id = "Bradley",
		name = "IFV",
		kind = "ground",
		slots = {
			{
				id = "shell",
				name = "AUTOCANNON",
				options = {
					{
						id = "heab",
						name = "AIRBURST",
						blurb = "Small bursting rounds. Good against soldiers behind cover.",
						icon = "shell_heab",
						scrap = 0,
						default = true,
						stats = {
							{ name = "BLAST", value = 0.64, text = "16" },
							{ name = "VS VEHICLES", value = 0.5, text = "100%" },
							{ name = "ROUND SPEED", value = 0.67, text = "625" },
							{ name = "FIRE RATE", value = 1, text = "200" }
						}
					},
					{
						id = "ap",
						name = "AP ROUNDS",
						blurb = "Fast, flat rounds that punch into vehicles. Almost no blast.",
						icon = "shell_ifv_ap",
						scrap = 3000,
						rank = 4,
						stats = {
							{ name = "BLAST", value = 0.2, text = "5" },
							{ name = "VS VEHICLES", value = 0.9, text = "180%" },
							{ name = "ROUND SPEED", value = 1, text = "937" },
							{ name = "FIRE RATE", value = 1, text = "200" }
						},
						fx = {
							cannon = {
								speed = 937,
								drag = 0.0004,
								size = 0.3,
								hullWear = 2.4,
								damage = 50,
								blast = {
									radius = 5,
									curve = {
										{ 0.25, 1 },
										{ 0.9, 0.2 }
									},
									shock = 2,
									shockRadius = 7
								}
							}
						}
					},
					{
						id = "he",
						name = "HEAVY HE",
						blurb = "Half the rounds, fired slower, each with a much bigger blast.",
						icon = "shell_ifv_he",
						scrap = 2500,
						rank = 2,
						stats = {
							{ name = "BLAST", value = 0.88, text = "22" },
							{ name = "VS VEHICLES", value = 0.6, text = "120%" },
							{ name = "ROUND SPEED", value = 0.59, text = "550" },
							{ name = "FIRE RATE", value = 0.5, text = "100" }
						},
						fx = {
							cannon = {
								shells = 6,
								spacing = 0.6,
								speed = 550,
								drag = 0.001,
								size = 0.6,
								hullWear = 1.6,
								damage = 70,
								blast = {
									radius = 22,
									curve = {
										{ 0.25, 1 },
										{ 0.9, 0.2 }
									},
									shock = 2,
									shockRadius = 30
								},
								fx = 0.5
							}
						}
					}
				}
			},
			{
				id = "launcher",
				name = "LAUNCHER",
				options = {
					{
						id = "twin",
						name = "TWIN ROCKETS",
						blurb = "Two rockets in the box. One comes back every 8 seconds.",
						icon = "launcher_twin",
						scrap = 0,
						default = true,
						stats = {
							{ name = "ROCKETS", value = 0.5, text = "2" },
							{ name = "RELOAD", value = 0.75, text = "8 S" }
						}
					},
					{
						id = "salvo",
						name = "ROCKET SALVO",
						blurb = "Four rockets you can fire in a quick burst, but each takes longer to come back.",
						icon = "launcher_salvo",
						scrap = 3500,
						rank = 6,
						stats = {
							{ name = "ROCKETS", value = 1, text = "4" },
							{ name = "RELOAD", value = 0.45, text = "12 S" }
						},
						fx = {
							launcher = { count = 4, spacing = 0.35, refill = 12 }
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
						blurb = "The IFV as it rolls out of the factory.",
						icon = "up_none",
						scrap = 0,
						default = true,
						stats = {
							{ name = "ARMOR", value = 0.55, text = "100%" },
							{ name = "RELOAD", value = 0.6, text = "2.4 S" }
						}
					},
					{
						id = "plating",
						name = "REACTIVE PLATING",
						blurb = "Extra plates soak up rockets and shells: blasts hurt the hull 10% less.",
						icon = "up_plating",
						scrap = 4000,
						rank = 8,
						stats = {
							{ name = "ARMOR", value = 0.61, text = "110%" },
							{ name = "RELOAD", value = 0.6, text = "2.4 S" }
						},
						fx = { blastWear = 0.9 }
					},
					{
						id = "loader",
						name = "FAST LOADER",
						blurb = "A fresh belt is in the gun sooner.",
						icon = "up_loader",
						scrap = 5000,
						rank = 10,
						stats = {
							{ name = "ARMOR", value = 0.55, text = "100%" },
							{ name = "RELOAD", value = 0.75, text = "2.0 S" }
						},
						fx = {
							refillK = 5 / 6
						}
					}
				}
			}
		}
	}
}