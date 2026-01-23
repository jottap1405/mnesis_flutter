#!/usr/bin/env python3
"""
Demonstration of Enhanced Compact Format Statusline.

Shows the complete enhanced statusline format with all components
and icons working through the full integration pipeline.

Author: FlowForge Team
Since: 2.1.0
"""

from statusline import FlowForgeStatusLine, FormattingContext, MilestoneModeFormatterAdapter
from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData


def main():
    """Run enhanced statusline demonstration."""
    print("=" * 120)
    print("ENHANCED COMPACT FORMAT STATUSLINE DEMONSTRATION")
    print("=" * 120)
    print()

    # Initialize components
    statusline = FlowForgeStatusLine()
    adapter = MilestoneModeFormatterAdapter(statusline)

    # Example 1: Current state simulation
    print("1. CURRENT STATUS (As requested):")
    print("-" * 80)
    print("OLD FORMAT:")
    print("  [FlowForge] v2.1-statusline-milestone-mode(3/4):30m")
    print()
    print("NEW ENHANCED FORMAT:")

    current_context = FormattingContext(
        issue_id="423",
        project_name="FlowForge",
        version="v2.1",
        milestone_data={
            "name": "v2.1-statusline-milestone-mode",
            "tasks_completed": 3,
            "tasks_total": 4,
            "time_remaining": "30m"
        },
        git_branch="feature/423-work",
        context_usage=85.0,
        model_name="Opus 4.1",
        mode="milestone",
        timer_active=True
    )

    result = adapter.format(current_context)
    print(f"  {result}")
    print()

    # Example 2: Different states
    print("2. VARIOUS STATES:")
    print("-" * 80)

    states = [
        {
            "description": "Active Development (High Context)",
            "context": FormattingContext(
                milestone_data={
                    "name": "feature-development",
                    "tasks_completed": 5,
                    "tasks_total": 10,
                    "time_remaining": "2h"
                },
                git_branch="feature/new-api",
                context_usage=92.5,
                model_name="Claude-3-Opus",
                timer_active=True
            )
        },
        {
            "description": "Bug Fix Session (Low Context, Inactive)",
            "context": FormattingContext(
                milestone_data={
                    "name": "hotfix-critical-bug",
                    "tasks_completed": 1,
                    "tasks_total": 1,
                    "time_remaining": "0m"
                },
                git_branch="hotfix/security-patch",
                context_usage=15.0,
                model_name="Sonnet",
                timer_active=False
            )
        },
        {
            "description": "Sprint Planning (No Context)",
            "context": FormattingContext(
                milestone_data={
                    "name": "sprint-42-planning",
                    "tasks_completed": 0,
                    "tasks_total": 25,
                    "time_remaining": "5h"
                },
                git_branch="planning/sprint-42",
                context_usage=0,
                model_name="GPT-4",
                timer_active=True
            )
        },
        {
            "description": "Long Running Task",
            "context": FormattingContext(
                milestone_data={
                    "name": "data-migration",
                    "tasks_completed": 150,
                    "tasks_total": 500,
                    "time_remaining": "3.5h"
                },
                git_branch="feature/database-migration",
                context_usage=45.0,
                model_name="Haiku",
                timer_active=True
            )
        }
    ]

    for state in states:
        print(f"\n{state['description']}:")
        result = adapter.format(state['context'])
        print(f"  {result}")

    # Example 3: Time format demonstrations
    print("\n3. TIME FORMAT CONVERSIONS:")
    print("-" * 80)

    time_formats = ["15m", "1h", "2.5h", "00:45", "01:30", "0.75h"]

    for time_format in time_formats:
        context = FormattingContext(
            milestone_data={
                "name": "time-demo",
                "tasks_completed": 1,
                "tasks_total": 2,
                "time_remaining": time_format
            },
            git_branch="test",
            model_name="Model",
            timer_active=True
        )
        result = adapter.format(context)
        # Extract just the time part for clarity
        time_part = result.split("⏱️")[1].split("|")[0].strip()
        print(f"  Input: {time_format:8} -> Output time: {time_part}")

    # Example 4: Component visibility
    print("\n4. COMPONENT VISIBILITY:")
    print("-" * 80)

    print("\nWith all components:")
    full_context = FormattingContext(
        milestone_data={
            "name": "full-display",
            "tasks_completed": 7,
            "tasks_total": 10,
            "time_remaining": "45m"
        },
        git_branch="feature/complete",
        context_usage=75.0,
        model_name="Claude-3-Opus",
        timer_active=True
    )
    print(f"  {adapter.format(full_context)}")

    print("\nWithout context usage:")
    no_context = FormattingContext(
        milestone_data={
            "name": "no-context",
            "tasks_completed": 3,
            "tasks_total": 5,
            "time_remaining": "20m"
        },
        git_branch="feature/simple",
        context_usage=0,
        model_name="Claude",
        timer_active=True
    )
    print(f"  {adapter.format(no_context)}")

    print("\nInactive timer:")
    inactive = FormattingContext(
        milestone_data={
            "name": "paused-work",
            "tasks_completed": 2,
            "tasks_total": 8,
            "time_remaining": "1h"
        },
        git_branch="feature/paused",
        context_usage=50.0,
        model_name="Model",
        timer_active=False
    )
    print(f"  {adapter.format(inactive)}")

    # Summary
    print("\n" + "=" * 120)
    print("ENHANCED FORMAT FEATURES:")
    print("-" * 80)
    print("✅ Icons for visual clarity: 🎯 milestone, ⏱️ time, 🌿 branch, 📊 context")
    print("✅ All components displayed: milestone, tasks, time, branch, context, model, timer")
    print("✅ Smart context display: Only shows 📊 when context > 0")
    print("✅ Timer status indication: ● Active / ○ Inactive")
    print("✅ Time format normalization: All times converted to minutes")
    print("✅ Proper spacing and separators for readability")
    print("=" * 120)


if __name__ == "__main__":
    main()