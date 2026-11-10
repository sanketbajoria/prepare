# The Semantic Layer Confusion: What It Actually Is, and What Modern Architecture Is Choosing

_Everyone is building one. Almost nobody means the same thing._

_Published Jul 28, 2026 · Updated Aug 11, 2026 · Free: No_

If you've sat in a data architecture review recently, you've probably heard the phrase "semantic layer" dropped at least twice and watched two people nod as if they understood each other, when they were actually picturing completely different things. One was thinking about a dbt metrics file. Another was thinking about a Power BI dataset. A third had a knowledge graph in mind. Nobody corrected anyone.

This confusion is not a sign that people don't know what they're doing. It's a sign that the term has been stretched across genuinely different problems, and the industry hasn't agreed on language yet.

Let's fix that.

<picture>
  <source media="(max-width: 768px)" srcset="/img/medium/700/1*lG_xfUtlHvU2SPrbYcJmbw.png 1x">
  <source media="(min-width: 769px)" srcset="/img/medium/2000/1*lG_xfUtlHvU2SPrbYcJmbw.png 1x">
  <img src="/img/medium/700/1*lG_xfUtlHvU2SPrbYcJmbw.png" alt="None" width="1536" height="1024" loading="lazy" data-zoom-src="/img/medium/4000/1*lG_xfUtlHvU2SPrbYcJmbw.png" class="prose-image"/>
</picture>

### Why the Confusion Exists

The phrase "semantic layer" originates in Business Intelligence, circa the 1990s. It described a mapping between physical database tables with their column names and surrogate keys and a friendlier representation that a business analyst could navigate. The idea was simple: translate technical schemas into business concepts.

Then data platforms exploded. Clouds, lakehouses, streaming pipelines, AI. Each new layer of complexity brought a new variant of the same question: _where do we define what things mean?_ And each domain answered it independently, naming its answer a "semantic layer."

The result is five distinct technologies wearing the same label.

### The Five Types — Clearly Separated

### 1. The BI / Reporting Semantic Layer

**Examples:** Power BI semantic model, Looker Explores, MicroStrategy metrics store, SAP BW.

**What it actually does:** Wraps a data warehouse in a tool-specific, user-friendly model. Pre-defines joins, hierarchies, measures, and dimension labels. The "semantics" are shallow it's mostly renaming columns and pre-computing aggregations so a business analyst can drag and drop without writing SQL.

**The catch:** It's coupled to a single tool. A Power BI semantic model means nothing to Databricks. A Looker Explore doesn't travel to Tableau. These layers are consumption-layer artifacts, not shared enterprise assets.

**Use it when:** Your primary consumer is a business analyst using a specific tool, and consistency within that tool is sufficient. Don't expect it to solve cross-system alignment.

### 2. The Metric Layer

**Examples:** dbt MetricFlow, Cube.dev, AtScale, Metriql.

**What it actually does:** Provides a single place to define how business metrics are calculated revenue, churn, days of cover, whatever matters to your organization so that every downstream consumer computes the same number from the same logic. It's version-controlled, testable, and tool-agnostic.

**The breakthrough:** This was the insight missing from BI semantic layers. If your finance team defines "net revenue" differently in Power BI than your operations team defines it in their Python notebook, you have a governance problem that no amount of dashboard polish will fix. The metric layer makes the definition the source of truth, not the visualization.

**The limitation:** It knows how to compute metrics. It does not know what entities mean. It cannot tell you whether "Customer 4821" in your CRM is the same legal entity as "Buyer XY-4821" in your ERP. It handles math, not identity.

**Use it when:** You have multiple BI tools or data consumers and you're tired of arguing about whose numbers are correct. Pair it with a data warehouse or lakehouse.

### 3. The Virtual / Federated Semantic Layer

**Examples:** Dremio, Trino, Starburst, Apache Arrow Flight SQL.

**What it actually does:** Presents a unified SQL surface over heterogeneous physical stores object storage, relational databases, cloud warehouses, streaming systems without copying data. The "semantic" component is primarily schema unification and access control. You write one query; the engine figures out where the data lives.

**The distinction:** This is primarily a _physical access_ problem solution, not a _meaning_ problem solution. It does not know that two tables from different systems represent the same business concept. It just lets you query both from the same interface.

**Use it when:** Data lives in multiple stores, movement is expensive or slow, and your bottleneck is access not conceptual alignment. Ideal as the federation layer in a lakehouse architecture.

### 4. The Ontology / Knowledge Graph Layer

**Examples:** Stardog, Metaphactory, TopQuadrant, Cambridge Semantics, Amazon Neptune.

**What it actually does:** Models the _meaning_ of enterprise data what entities exist, how they relate to each other, and what rules apply using formal languages like OWL, SHACL, and RDF. Assigns canonical, persistent identifiers (IRIs) to real-world things: a vendor, a part, a legal entity, a process. Enables inference: if A is a subclass of B, the system can derive facts about A from rules defined for B.

**Why this is categorically different:** Every other layer in this list assumes your data is already clean and consistently labelled. The knowledge graph layer is what you reach for when it isn't when the same supplier appears under three different names across four systems, when "part" means something slightly different in engineering and procurement, when a compliance audit requires you to trace the lineage of a decision across systems that were never designed to talk to each other.

This is also the layer that survives system migrations. Source systems come and go; a canonical ontology with stable IRIs can outlast the ERP that originally populated it.

**Use it when:** You have cross-domain identity problems, multi-hop relationship queries, compliance or regulatory reasoning requirements, or you need a shared conceptual model that multiple systems can align to not just one tool's version of it.

### 5. The AI / LLM Context Layer

**Examples:** Databricks Genie Ontology, GraphRAG (Microsoft), vector + KG hybrids.

**What it actually does:** Provides structured grounding for language models so they can answer questions about enterprise data without hallucinating entity names, relationships, or calculations. This might be a natural-language-to-SPARQL or NL-to-SQL translation backed by an ontology, or a retrieval-augmented generation pipeline that queries a knowledge graph before generating an answer.

**Why it exists separately:** Language models are powerful but stateless they know nothing about your specific organisation's data, and they will confidently invent facts to fill that gap. The AI context layer is the bridge between the model's reasoning capability and your organisation's actual knowledge. Without it, enterprise AI applications are brittle at best, dangerous at worst.

**The relationship to ontologies:** This layer is almost always _derived from_ the knowledge graph layer, not a replacement for it. The ontology provides the structured facts; the AI context layer wraps them in a form the model can use for retrieval, grounding, and tool-calling.

**Use it when:** You are building agent-based systems, chatbots over enterprise data, or any AI workflow that needs to make factual claims about your organisation's entities, processes, or metrics.

### The Decision Framework

Before picking a tool, ask which problem you are actually solving. The honest answer for most mature enterprises is that you need more than one. These layers solve orthogonal problems and stack well:

- The virtual/federated layer handles _where_ data lives
- The metric layer handles _how numbers are computed_
- The ontology layer handles _what things mean_
- The BI layer handles _how analysts see results_
- The AI context layer handles _what the model knows_

The mistake is trying to force one layer to do all five jobs.

### **Two things are becoming standard infrastructure:**

The **metric layer** is now a commodity. dbt MetricFlow ships with dbt Core. Any team running dbt should define metrics here, not inside their BI tool. This is no longer an advanced choice — it's the expected baseline.

The **ontology / knowledge graph layer** is having its enterprise moment. For years it was associated with Google's Knowledge Panel and academic research. Now enterprises dealing with complex supply chains, CSRD and GDPR compliance, and AI deployment are discovering the problems they have entity resolution, cross-domain reasoning, multi-hop lineage are exactly what RDF/OWL was designed to solve.

### The Governance Shift Nobody Talks About

In the BI era, knowledge lived inside tools. The Looker Explore, the Power BI dataset, the SAP BW hierarchy. Change the tool, lose the knowledge. Add a new tool, rebuild it from scratch.

In the modern model, knowledge lives in the ontology. BI tools, metric layers, and AI applications all derive from it. The ontology becomes the enterprise's durable, system-independent model of what things mean versioned in Git, validated by SHACL in CI/CD, maintained by a small team of ontology engineers and domain experts.

This is a different kind of engineering work. It requires people who can model a "part" in a way that satisfies both procurement and engineering without collapsing the distinction between them. The payoff is an architecture that accumulates knowledge over time, rather than resetting with every tool migration.

### A Maturity Model to Orient Yourself

You don't need all five layers on day one. Here's a realistic progression and to make each level concrete, a single company, Volta Motors (a fictional EV manufacturer), runs through all five.

<picture>
  <source media="(max-width: 768px)" srcset="/img/medium/700/1*pcBh7nY_7dK8PYNYy8wrDg.png 1x">
  <source media="(min-width: 769px)" srcset="/img/medium/2000/1*pcBh7nY_7dK8PYNYy8wrDg.png 1x">
  <img src="/img/medium/700/1*pcBh7nY_7dK8PYNYy8wrDg.png" alt="None" width="2280" height="1728" loading="lazy" data-zoom-src="/img/medium/4000/1*pcBh7nY_7dK8PYNYy8wrDg.png" class="prose-image"/>
</picture>

Most enterprises sit between Level 1 and Level 3. Level 4 is where competitive advantage from AI materialises. Level 5 is what the most forward-thinking organisations are building toward now.

> The diagram below follows Volta Motors across all five levels. Each row shows the same pattern: the pain the organisation is living with on the left, the layer that addresses it in the centre, and what concretely changes on the right. The progression is cumulative each level builds on the one below it. Level 3 is the pivotal step: it is where meaning enters the architecture, and where every subsequent capability AI grounding, reasoning, compliance traceability becomes possible.

<picture>
  <source media="(max-width: 768px)" srcset="/img/medium/700/1*CfGulwYsg8ucVigSpF6ing.png 1x">
  <source media="(min-width: 769px)" srcset="/img/medium/2000/1*CfGulwYsg8ucVigSpF6ing.png 1x">
  <img src="/img/medium/700/1*CfGulwYsg8ucVigSpF6ing.png" alt="None" width="2720" height="2960" loading="lazy" data-zoom-src="/img/medium/4000/1*CfGulwYsg8ucVigSpF6ing.png" class="prose-image"/>
</picture>

The tools exist at every level. What is waiting is the willingness to build past Level 2 , past access and metrics into the layer where meaning lives. That is where the architecture stops being fragile.

The semantic layer is not one thing. It never was. The sooner we stop treating it like one, the sooner we can build architectures that actually hold.
