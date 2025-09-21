# frozen_string_literal: true

module RailsAi
  module Agents
    # Research Agent - Specialized in gathering and analyzing information
    class ResearchAgent < BaseAgent
      def initialize(name: "ResearchAgent", **opts)
        super(
          name: name,
          role: "Research Specialist",
          capabilities: [:research, :analysis, :data_gathering, :fact_checking],
          **opts
        )
      end

      def research_topic(topic, depth: :standard)
        return "[stubbed] Research on #{topic}" if RailsAi.config.stub_responses

        research_prompt = build_research_prompt(topic, depth)
        result = think(research_prompt, context: { topic: topic, depth: depth })
        
        remember("research_#{topic}_#{Time.now.to_i}", result, importance: :high)
        result
      end

      def fact_check(claim)
        return "[stubbed] Fact check: #{claim}" if RailsAi.config.stub_responses

        fact_check_prompt = build_fact_check_prompt(claim)
        result = think(fact_check_prompt, context: { claim: claim })
        
        remember("fact_check_#{claim.hash}", result, importance: :normal)
        result
      end

      private

      def build_research_prompt(topic, depth)
        depth_instructions = case depth
        when :shallow
          "Provide a brief overview"
        when :standard
          "Provide a comprehensive analysis"
        when :deep
          "Provide an in-depth, detailed analysis with multiple perspectives"
        end

        <<~PROMPT
          As a research specialist, conduct #{depth_instructions} on the topic: #{topic}

          Include:
          - Key facts and data points
          - Multiple perspectives and viewpoints
          - Recent developments and trends
          - Potential implications and consequences
          - Sources and references where applicable

          Ensure accuracy and objectivity in your research.
        PROMPT
      end

      def build_fact_check_prompt(claim)
        <<~PROMPT
          As a fact-checking specialist, verify the following claim: "#{claim}"

          Provide:
          - Verification status (true, false, partially true, unverifiable)
          - Evidence supporting or refuting the claim
          - Context and nuances
          - Confidence level in your assessment
          - Sources used for verification

          Be objective and evidence-based in your analysis.
        PROMPT
      end
    end

    # Creative Agent - Specialized in creative tasks and ideation
    class CreativeAgent < BaseAgent
      def initialize(name: "CreativeAgent", **opts)
        super(
          name: name,
          role: "Creative Specialist",
          capabilities: [:creative_writing, :ideation, :design_thinking, :storytelling],
          **opts
        )
      end

      def brainstorm(topic, quantity: 10)
        return Array.new(quantity) { "[stubbed] Creative idea #{_1 + 1}" } if RailsAi.config.stub_responses

        brainstorm_prompt = build_brainstorm_prompt(topic, quantity)
        result = think(brainstorm_prompt, context: { topic: topic, quantity: quantity })
        
        ideas = parse_ideas(result)
        remember("brainstorm_#{topic}_#{Time.now.to_i}", ideas, importance: :high)
        ideas
      end

      def write_story(prompt, genre: :general, length: :medium)
        return "[stubbed] Story: #{prompt}" if RailsAi.config.stub_responses

        story_prompt = build_story_prompt(prompt, genre, length)
        result = think(story_prompt, context: { prompt: prompt, genre: genre, length: length })
        
        remember("story_#{prompt.hash}", result, importance: :normal)
        result
      end

      def design_concept(description, style: :modern)
        return "[stubbed] Design concept: #{description}" if RailsAi.config.stub_responses

        design_prompt = build_design_prompt(description, style)
        result = think(design_prompt, context: { description: description, style: style })
        
        remember("design_#{description.hash}", result, importance: :normal)
        result
      end

      private

      def build_brainstorm_prompt(topic, quantity)
        <<~PROMPT
          As a creative specialist, brainstorm #{quantity} innovative and creative ideas related to: #{topic}

          Requirements:
          - Be creative and think outside the box
          - Ideas should be practical and implementable
          - Include both conventional and unconventional approaches
          - Consider different perspectives and angles
          - Make each idea unique and distinct

          Format your response as a numbered list of ideas.
        PROMPT
      end

      def build_story_prompt(prompt, genre, length)
        length_guidance = case length
        when :short then "Write a short story (1-2 pages)"
        when :medium then "Write a medium-length story (3-5 pages)"
        when :long then "Write a longer story (6+ pages)"
        end

        <<~PROMPT
          As a creative writer, #{length_guidance} based on: #{prompt}

          Genre: #{genre}
          Requirements:
          - Engaging plot and characters
          - Clear narrative structure
          - Appropriate tone and style for the genre
          - Creative and original content
          - Well-developed dialogue and descriptions

          Create an immersive and compelling story.
        PROMPT
      end

      def build_design_prompt(description, style)
        <<~PROMPT
          As a design specialist, create a design concept for: #{description}

          Style: #{style}
          Requirements:
          - Clear visual description
          - Functional considerations
          - Aesthetic appeal
          - User experience focus
          - Innovative elements

          Provide a detailed design concept with visual descriptions and rationale.
        PROMPT
      end

      def parse_ideas(result)
        # Extract numbered ideas from the response
        result.scan(/^\d+\.\s*(.+)$/m).flatten.map(&:strip)
      end
    end

    # Technical Agent - Specialized in technical tasks and problem-solving
    class TechnicalAgent < BaseAgent
      def initialize(name: "TechnicalAgent", **opts)
        super(
          name: name,
          role: "Technical Specialist",
          capabilities: [:programming, :debugging, :system_design, :troubleshooting],
          **opts
        )
      end

      def solve_problem(problem_description, approach: :systematic)
        return "[stubbed] Solution for: #{problem_description}" if RailsAi.config.stub_responses

        problem_prompt = build_problem_solving_prompt(problem_description, approach)
        result = think(problem_prompt, context: { problem: problem_description, approach: approach })
        
        remember("solution_#{problem_description.hash}", result, importance: :high)
        result
      end

      def code_review(code, language: :ruby)
        return "[stubbed] Code review for #{language} code" if RailsAi.config.stub_responses

        review_prompt = build_code_review_prompt(code, language)
        result = think(review_prompt, context: { code: code, language: language })
        
        remember("code_review_#{code.hash}", result, importance: :normal)
        result
      end

      def design_system(requirements)
        return "[stubbed] System design for: #{requirements}" if RailsAi.config.stub_responses

        design_prompt = build_system_design_prompt(requirements)
        result = think(design_prompt, context: { requirements: requirements })
        
        remember("system_design_#{requirements.hash}", result, importance: :high)
        result
      end

      private

      def build_problem_solving_prompt(problem, approach)
        approach_guidance = case approach
        when :systematic
          "Use a systematic, step-by-step approach"
        when :creative
          "Think creatively and consider unconventional solutions"
        when :analytical
          "Focus on data analysis and logical reasoning"
        end

        <<~PROMPT
          As a technical specialist, solve this problem: #{problem}

          Approach: #{approach_guidance}

          Provide:
          - Problem analysis and root cause identification
          - Multiple solution options with pros/cons
          - Recommended solution with implementation steps
          - Risk assessment and mitigation strategies
          - Testing and validation approach

          Be thorough and technically sound in your analysis.
        PROMPT
      end

      def build_code_review_prompt(code, language)
        <<~PROMPT
          As a technical specialist, review this #{language} code:

          ```#{language}
          #{code}
          ```

          Provide:
          - Code quality assessment
          - Potential bugs or issues
          - Performance considerations
          - Best practices adherence
          - Suggestions for improvement
          - Security considerations

          Be constructive and specific in your feedback.
        PROMPT
      end

      def build_system_design_prompt(requirements)
        <<~PROMPT
          As a technical specialist, design a system based on these requirements: #{requirements}

          Provide:
          - High-level architecture overview
          - Component breakdown and responsibilities
          - Data flow and interactions
          - Technology stack recommendations
          - Scalability considerations
          - Security and reliability measures
          - Implementation phases

          Be comprehensive and consider real-world constraints.
        PROMPT
      end
    end

    # Coordinator Agent - Specialized in managing and coordinating other agents
    class CoordinatorAgent < BaseAgent
      def initialize(name: "CoordinatorAgent", **opts)
        super(
          name: name,
          role: "Coordination Specialist",
          capabilities: [:coordination, :project_management, :resource_allocation, :conflict_resolution],
          **opts
        )
      end

      def coordinate_task(task, available_agents)
        return "[stubbed] Coordination plan for: #{task[:description]}" if RailsAi.config.stub_responses

        coordination_prompt = build_coordination_prompt(task, available_agents)
        result = think(coordination_prompt, context: { task: task, agents: available_agents })
        
        remember("coordination_#{task[:id]}", result, importance: :high)
        result
      end

      def resolve_conflict(conflict_description, involved_agents)
        return "[stubbed] Conflict resolution for: #{conflict_description}" if RailsAi.config.stub_responses

        conflict_prompt = build_conflict_resolution_prompt(conflict_description, involved_agents)
        result = think(conflict_prompt, context: { conflict: conflict_description, agents: involved_agents })
        
        remember("conflict_resolution_#{Time.now.to_i}", result, importance: :high)
        result
      end

      def optimize_workflow(workflow_description, constraints)
        return "[stubbed] Workflow optimization for: #{workflow_description}" if RailsAi.config.stub_responses

        optimization_prompt = build_optimization_prompt(workflow_description, constraints)
        result = think(optimization_prompt, context: { workflow: workflow_description, constraints: constraints })
        
        remember("workflow_optimization_#{Time.now.to_i}", result, importance: :normal)
        result
      end

      private

      def build_coordination_prompt(task, agents)
        agent_info = agents.map { |a| "#{a.name} (#{a.role}): #{a.capabilities.join(', ')}" }.join("\n")

        <<~PROMPT
          As a coordination specialist, create a coordination plan for this task: #{task[:description]}

          Available agents:
          #{agent_info}

          Create a plan that:
          - Assigns appropriate roles to each agent
          - Defines clear responsibilities and deliverables
          - Establishes communication protocols
          - Sets timelines and milestones
          - Identifies dependencies and coordination points
          - Includes quality assurance measures

          Provide a detailed coordination strategy.
        PROMPT
      end

      def build_conflict_resolution_prompt(conflict, agents)
        agent_info = agents.map { |a| "#{a.name} (#{a.role})" }.join(", ")

        <<~PROMPT
          As a coordination specialist, resolve this conflict: #{conflict}

          Involved agents: #{agent_info}

          Provide:
          - Conflict analysis and root causes
          - Mediation strategy
          - Resolution approach
          - Prevention measures
          - Communication guidelines
          - Follow-up procedures

          Focus on fair and constructive resolution.
        PROMPT
      end

      def build_optimization_prompt(workflow, constraints)
        <<~PROMPT
          As a coordination specialist, optimize this workflow: #{workflow}

          Constraints: #{constraints}

          Provide:
          - Current workflow analysis
          - Bottleneck identification
          - Optimization opportunities
          - Improved workflow design
          - Implementation strategy
          - Performance metrics

          Focus on efficiency and effectiveness improvements.
        PROMPT
      end
    end
  end
end
