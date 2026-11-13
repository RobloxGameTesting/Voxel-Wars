return {
	Name = "dailyday",
	Aliases = {},
	Description = "Test the daily supply: day1..day7 sets the day your next claim pays, noskin takes the streak skin back.",
	Group = "DefaultAdmin",
	Args = {
		{ Type = "dailyTest", Name = "action", Description = "day1..day7 or noskin" }
	}
}