[%# USE Dumper; Dumper.dump(repo) %]
<h2 id="$repo.name">$repo.title</h2>
[% IF repo.description -%]
  <p class="description">[% repo.description | html %]</p>
[%- END %]
[% IF repo.date -%]
  <p class="date">[% repo.date | html %]</p>
[%- END %]
<ul>
[% FOREACH form IN repo.forms.keys %]
  <li>
    $form: 
    [% FOREACH type IN repo.forms.$form.values %]
      <a href="$repo.name/$type.file">$type.type</a>
    [% END %]
  </li>
[% END %]
  <li>
    <a href="https://github.com/jakobib/$repo.name">github:$repo.name</a>
  </li>
</ul>
