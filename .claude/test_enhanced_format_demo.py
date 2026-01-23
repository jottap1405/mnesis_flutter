#!/usr/bin/env python3
"""
Demo script to test the enhanced compact format implementation.

Shows how the enhanced format displays with various data configurations.

Author: FlowForge Team
Since: 2.1.0
"""

from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData


def main():
    """Run demo of enhanced compact format."""
    formatter = MilestoneModeFormatter()

    print("=" * 80)
    print("ENHANCED COMPACT FORMAT DEMONSTRATION")
    print("=" * 80)

    # Test Case 1: Full data with all components
    print("\n1. Full Data Example:")
    print("-" * 40)
    data1 = MilestoneStatusLineData(
        milestone_name="v2.1-statusline-milestone-mode",
        tasks_completed=3,
        tasks_total=4,
        eta_remaining="30m",
        git_branch="feature/423-work",
        model_name="Opus 4.1",
        context_usage=85.0,
        timer_active=True
    )
    result1 = formatter.format_enhanced(data1)
    print(f"Result: {result1}")
    print(f"Length: {len(result1)} characters")

    # Test Case 2: Without context usage
    print("\n2. Without Context Usage:")
    print("-" * 40)
    data2 = MilestoneStatusLineData(
        milestone_name="v2.1-statusline-milestone-mode",
        tasks_completed=3,
        tasks_total=4,
        eta_remaining="45m",
        git_branch="feature/423-work",
        model_name="Claude-3-Opus",
        context_usage=0,
        timer_active=True
    )
    result2 = formatter.format_enhanced(data2)
    print(f"Result: {result2}")
    print(f"Length: {len(result2)} characters")

    # Test Case 3: Inactive timer
    print("\n3. Inactive Timer:")
    print("-" * 40)
    data3 = MilestoneStatusLineData(
        milestone_name="bug-fix-session",
        tasks_completed=1,
        tasks_total=1,
        eta_remaining="0m",
        git_branch="hotfix/critical",
        model_name="Sonnet",
        context_usage=25.5,
        timer_active=False
    )
    result3 = formatter.format_enhanced(data3)
    print(f"Result: {result3}")
    print(f"Length: {len(result3)} characters")

    # Test Case 4: Long milestone name
    print("\n4. Long Milestone Name:")
    print("-" * 40)
    data4 = MilestoneStatusLineData(
        milestone_name="super-long-milestone-name-for-testing-truncation",
        tasks_completed=10,
        tasks_total=100,
        eta_remaining="2h",  # Will convert to 120m
        git_branch="main",
        model_name="GPT-4",
        context_usage=50.0,
        timer_active=True
    )
    result4 = formatter.format_enhanced(data4)
    print(f"Result: {result4}")
    print(f"Length: {len(result4)} characters")

    # Test Case 5: Time format variations
    print("\n5. Time Format Variations:")
    print("-" * 40)
    time_variations = ["30m", "1h", "2.5h", "01:30", "00:45"]
    for time_val in time_variations:
        data = MilestoneStatusLineData(
            milestone_name="time-test",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining=time_val,
            git_branch="test",
            model_name="Model",
            timer_active=True
        )
        result = formatter.format_enhanced(data)
        print(f"  {time_val:8} -> {result}")

    # Comparison with old format
    print("\n6. Format Comparison:")
    print("-" * 40)
    comparison_data = MilestoneStatusLineData(
        milestone_name="v2.1-statusline-milestone-mode",
        tasks_completed=3,
        tasks_total=4,
        eta_remaining="30m",
        git_branch="feature/423-work",
        model_name="Opus 4.1",
        context_usage=85.0,
        timer_active=True
    )

    old_format = formatter.format(comparison_data)
    new_format = formatter.format_enhanced(comparison_data)

    print(f"Old Format: {old_format}")
    print(f"            Length: {len(old_format)} chars")
    print(f"New Format: {new_format}")
    print(f"            Length: {len(new_format)} chars")

    print("\n" + "=" * 80)
    print("DEMONSTRATION COMPLETE")
    print("=" * 80)


if __name__ == "__main__":
    main()