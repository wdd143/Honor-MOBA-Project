namespace HonorMoba.Core
{
    /// <summary>Team assignment used by heroes, minions and structures.</summary>
    public enum TeamId
    {
        Neutral = 0,
        Blue = 1,
        Red = 2
    }

    public static class TeamIdExtensions
    {
        public static bool IsEnemyOf(this TeamId team, TeamId other)
        {
            return team != TeamId.Neutral &&
                   other != TeamId.Neutral &&
                   team != other;
        }
    }
}
